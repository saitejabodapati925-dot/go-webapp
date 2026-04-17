# Go Web Application

This repository contains a Go web application, a Docker image build, CI validation, SonarCloud quality checks, Trivy image scanning, and Terraform for Amazon EKS.

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

## Provision EKS

Terraform files:

```text
infra/terraform/eks
```

GitHub Actions workflow:

```text
.github/workflows/provision-eks.yaml
```

Prerequisites:

- Terraform `>= 1.5.7`
- AWS credentials with permission to create VPC and EKS resources
- AWS CLI for writing kubeconfig locally
- `kubectl`

Bootstrap example:

```bash
cd infra/terraform/eks
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --region us-east-1 --name go-webapp
```

## Looks like this

![Website](static/images/golang-website.png)
