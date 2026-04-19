# Go Web Application

This repository contains a Go web application, a Docker image build, CI validation, SonarCloud quality checks, and Trivy image scanning.

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

## Looks like this

![Website](static/images/golang-website.png)
