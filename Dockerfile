# syntax=docker/dockerfile:1.7

FROM golang:1.22.5-alpine AS builder

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/go-web-app .

FROM alpine:3.21

WORKDIR /app

RUN addgroup -S app && adduser -S -G app app

COPY --from=builder /out/go-web-app ./go-web-app
COPY --from=builder /src/static ./static

USER app

EXPOSE 8080

ENTRYPOINT ["./go-web-app"]
