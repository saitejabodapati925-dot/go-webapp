# Go Web Application

This repository contains a Go web application, a Docker image build, CI validation, SonarQube quality checks, Trivy image scanning, Terraform for Amazon EKS, and an Argo CD GitOps deployment path.

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

## CI

Workflow:

```text
.github/workflows/ci.yaml
```

## EKS and CD

Provisioning workflow:

```text
.github/workflows/provision-eks.yaml
```

GitOps deployment workflow:

```text
.github/workflows/cd.yaml
```

Infrastructure and deployment manifests:

```text
infra/terraform/eks
argocd
k8s
```

Deployment flow:

1. `CI` validates the app, runs SonarQube, scans the image with Trivy, and pushes a Docker image tagged as `sha-<commit>`.
2. `CD` runs only after successful `CI` on `main`.
3. `CD` updates `k8s/overlays/prod/kustomization.yaml` with the new image tag.
4. Argo CD watches this repository and syncs the updated manifest into EKS.

Required GitHub secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKERHUB_TOKEN
SONAR_TOKEN
```

Optional GitHub secrets:

```text
AWS_SESSION_TOKEN
ARGOCD_WEBHOOK_SECRET
GH_WEBHOOK_TOKEN
```

Required GitHub variables:

```text
DOCKERHUB_USERNAME
SONAR_HOST_URL
SONAR_PROJECT_KEY
```

To provision EKS and bootstrap Argo CD, run the `Provision EKS and Argo CD` workflow manually from GitHub Actions.

## Looks like this

![Website](static/images/golang-website.png)
