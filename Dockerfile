FROM golang:1.12-stretch AS builder

RUN go get github.com/xiam/openvpn-config-generator/cmd/ovpn-cfgen

FROM centos:7

COPY --from=builder /go/bin/ovpn-cfgen /usr/bin/

RUN yum install -y epel-release

RUN yum install -y \
	net-tools \
  openssl \
	openvpn \
	curl

WORKDIR /openvpn

COPY docker-entrypoint.sh /usr/bin

RUN mkdir -p config private

EXPOSE 1194/udp

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["ovpn-cfgen"]
