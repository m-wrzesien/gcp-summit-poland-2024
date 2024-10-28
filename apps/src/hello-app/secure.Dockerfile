FROM golang:1.23 AS builder

RUN mkdir -p /build
ADD . /build
WORKDIR /build

RUN go build -o app

FROM ubuntu:24.04

COPY --from=builder /build/app /

ENTRYPOINT ["/app"]