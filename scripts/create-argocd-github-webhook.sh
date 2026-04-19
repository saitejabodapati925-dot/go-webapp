#!/usr/bin/env bash
set -euo pipefail

: "${GH_WEBHOOK_TOKEN:?Set GH_WEBHOOK_TOKEN to a GitHub token with repository webhook permissions.}"
: "${ARGOCD_WEBHOOK_SECRET:?Set ARGOCD_WEBHOOK_SECRET to the same value configured in Argo CD.}"
: "${GITHUB_REPOSITORY:?Set GITHUB_REPOSITORY as owner/repo.}"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
argocd_host="$(kubectl get service argocd-server -n "${ARGOCD_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
argocd_ip="$(kubectl get service argocd-server -n "${ARGOCD_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

if [ -n "${argocd_host}" ]; then
  argocd_endpoint="${argocd_host}"
elif [ -n "${argocd_ip}" ]; then
  argocd_endpoint="${argocd_ip}"
else
  echo "argocd-server LoadBalancer endpoint is not ready." >&2
  exit 1
fi

payload_url="https://${argocd_endpoint}/api/webhook"
hooks_json="$(curl --fail-with-body --silent --show-error \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_WEBHOOK_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/hooks")"

existing_hook_id="$(python3 -c 'import json,sys; hooks=json.load(sys.stdin); url=sys.argv[1]; print(next((str(h["id"]) for h in hooks if h.get("config", {}).get("url") == url), ""))' "${payload_url}" <<< "${hooks_json}")"

payload="$(PAYLOAD_URL="${payload_url}" ARGOCD_WEBHOOK_SECRET="${ARGOCD_WEBHOOK_SECRET}" python3 -c 'import json,os; print(json.dumps({"name":"web","active":True,"events":["push"],"config":{"url":os.environ["PAYLOAD_URL"],"content_type":"json","secret":os.environ["ARGOCD_WEBHOOK_SECRET"],"insecure_ssl":"1"}}))')"

if [ -n "${existing_hook_id}" ]; then
  curl --fail-with-body --silent --show-error \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_WEBHOOK_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/hooks/${existing_hook_id}" \
    -d "${payload}" >/dev/null
  echo "Updated GitHub webhook ${existing_hook_id}: ${payload_url}"
else
  curl --fail-with-body --silent --show-error \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_WEBHOOK_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/hooks" \
    -d "${payload}" >/dev/null
  echo "Created GitHub webhook: ${payload_url}"
fi
