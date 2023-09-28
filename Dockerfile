FROM golang:1.21-alpine AS builder

RUN apk add --no-cache \
  git

RUN go install github.com/xiam/openvpn-config-generator/cmd/ovpn-cfgen@latest

FROM alpine:3.15

COPY --from=builder /go/bin/ovpn-cfgen /usr/bin/

RUN apk add --no-cache \
  iperf \
  shadow \
  openssl \
  openvpn

WORKDIR /openvpn

COPY docker-entrypoint.sh /usr/bin

RUN mkdir -p config private

EXPOSE 1194/udp

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["ovpn-cfgen"]
