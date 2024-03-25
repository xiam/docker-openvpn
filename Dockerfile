FROM golang:1.22-alpine AS builder

RUN apk add --no-cache \
  git

RUN go install github.com/xiam/openvpn-config-generator/cmd/ovpn-cfgen@9723757886b9db784aec2358c5a34beec78658c7

FROM alpine:3.19

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
