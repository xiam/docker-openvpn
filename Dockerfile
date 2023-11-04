FROM golang:1.21-alpine AS builder

RUN apk add --no-cache \
  git

RUN go install github.com/xiam/openvpn-config-generator/cmd/ovpn-cfgen@04aba3d118102d4d24e05f8ac441a30e0e8f44ee

FROM alpine:3.18

COPY --from=builder /go/bin/ovpn-cfgen /usr/bin/

RUN apk add --no-cache \
  iperf \
  shadow \
  openssl \
  iptables \
  openvpn

WORKDIR /openvpn

COPY docker-entrypoint.sh /usr/bin

RUN mkdir -p config private

EXPOSE 1194/udp

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["ovpn-cfgen"]
