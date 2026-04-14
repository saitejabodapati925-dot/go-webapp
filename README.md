# Go Web Application

This repository contains a Go web application, a Docker image build, CI validation, SonarCloud quality checks, Trivy image scanning, and a GitOps-style CD path for Argo CD and Kubernetes.

## Run locally

Start the app:

```bash
go run .
```

Then open:

```text
http://localhost:8080/home
```

Other routes:

```text
http://localhost:8080/courses
http://localhost:8080/about
http://localhost:8080/contact
```

## Test locally

```bash
go test ./...
go vet ./...
go build .
```

## Container image

Build the image locally:

```bash
docker build -t saitejabodapati925/go-webapp:local .
```

Run it:

```bash
docker run --rm -p 8080:8080 saitejabodapati925/go-webapp:local
```

## Kubernetes manifests

The Kubernetes manifests live here:

```text
k8s/base
k8s/overlays/prod
```

Preview the production overlay with Kustomize:

```bash
kubectl kustomize k8s/overlays/prod
```

Apply it manually if you want:

```bash
kubectl apply -k k8s/overlays/prod
```

## Argo CD

The Argo CD application manifest is here:

```text
argocd/go-webapp-application.yaml
```

After Argo CD is installed in your cluster, apply it with:

```bash
kubectl apply -f argocd/go-webapp-application.yaml
```

This application watches `k8s/overlays/prod` on the `main` branch and is configured for automated sync, pruning, and self-healing.

## CI and CD

CI workflow:

```text
.github/workflows/ci.yaml
```

CD workflow:

```text
.github/workflows/cd.yaml
```

How deployment works:

1. `CI` validates the app, runs SonarCloud, scans the container image, and pushes a Docker image tagged with `sha-<commit>`.
2. `CD` runs after a successful `CI` push on `main`.
3. `CD` updates `k8s/overlays/prod/kustomization.yaml` to the matching image tag.
4. Argo CD notices the Git change and deploys it to Kubernetes.

## Looks like this

![Website](static/images/golang-website.png)

