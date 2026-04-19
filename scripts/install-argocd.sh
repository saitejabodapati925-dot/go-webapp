#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_MANIFEST_URL="${ARGOCD_MANIFEST_URL:-https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml}"
ARGOCD_WEBHOOK_SECRET="${ARGOCD_WEBHOOK_SECRET:-}"

kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "${ARGOCD_NAMESPACE}" --server-side --force-conflicts -f "${ARGOCD_MANIFEST_URL}"

kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=180s
kubectl wait --for=condition=Established crd/appprojects.argoproj.io --timeout=180s

kubectl patch service argocd-server -n "${ARGOCD_NAMESPACE}" --type merge \
  -p '{"spec":{"type":"LoadBalancer"}}'

# Keep the demo cluster small enough for Free Tier-sized nodes.
kubectl scale deployment/argocd-dex-server -n "${ARGOCD_NAMESPACE}" --replicas=0
kubectl scale deployment/argocd-notifications-controller -n "${ARGOCD_NAMESPACE}" --replicas=0
kubectl scale deployment/argocd-applicationset-controller -n "${ARGOCD_NAMESPACE}" --replicas=0

if [[ -n "${ARGOCD_WEBHOOK_SECRET}" ]]; then
  encoded_secret="$(printf '%s' "${ARGOCD_WEBHOOK_SECRET}" | base64 | tr -d '\n')"
  kubectl patch secret argocd-secret -n "${ARGOCD_NAMESPACE}" --type merge \
    -p "{\"data\":{\"webhook.github.secret\":\"${encoded_secret}\"}}"
fi

if ! kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE}" --timeout=900s; then
  kubectl get pods -n "${ARGOCD_NAMESPACE}" -o wide
  kubectl describe deployment/argocd-server -n "${ARGOCD_NAMESPACE}"
  exit 1
fi

kubectl apply -f argocd/go-webapp-project.yaml
kubectl apply -f argocd/go-webapp-application.yaml

echo "Waiting for argocd-server external hostname..."
for _ in $(seq 1 60); do
  hostname="$(kubectl get service argocd-server -n "${ARGOCD_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
  ip="$(kubectl get service argocd-server -n "${ARGOCD_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"

  if [[ -n "${hostname}" ]]; then
    echo "ARGOCD_SERVER_URL=https://${hostname}"
    exit 0
  fi

  if [[ -n "${ip}" ]]; then
    echo "ARGOCD_SERVER_URL=https://${ip}"
    exit 0
  fi

  sleep 10
done

echo "Timed out waiting for argocd-server external hostname." >&2
kubectl get service argocd-server -n "${ARGOCD_NAMESPACE}"
exit 1
