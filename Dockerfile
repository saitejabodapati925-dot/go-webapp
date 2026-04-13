# syntax=docker/dockerfile:1.7

FROM golang:1.26.2-alpine AS builder

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY main.go ./
COPY static ./static

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/go-webapp .

FROM scratch

WORKDIR /app

COPY --from=builder /out/go-webapp ./go-webapp
COPY --from=builder /src/static ./static

USER 65532:65532

EXPOSE 8080

ENTRYPOINT ["./go-webapp"]
