DH_PARAMS_SIZE       ?= 2048
REMOTE_IP     ?= 127.0.0.1

DOCKER_IMAGE  ?= xiam/openvpn
CLIENT_NAME   ?= client

HOST_UID      ?= $(shell id -u)
HOST_GID      ?= $(shell id -g)

.PHONY: config

define docker_run
	docker run \
		--rm \
		-v $(PWD)/config:/openvpn/config \
		-v $(PWD)/private:/openvpn/private \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-t $(DOCKER_IMAGE) \
		$(1)
endef

all: docker-build config

clean:
	rm -rf config private

directories:
	mkdir -p private config

docker-build:
	docker build -t $(DOCKER_IMAGE) .

private/ca.key:
	$(call docker_run,ovpn-cfgen build-ca --workdir private)

private/server.key: private/ca.key private/dh.pem private/key.tlsauth
	$(call docker_run,ovpn-cfgen build-key-server --key private/ca.key --cert private/ca.crt --workdir private)

private/dh.pem:
	$(call docker_run,openssl dhparam -out private/dh.pem $(DH_PARAMS_SIZE))

private/key.tlsauth:
	$(call docker_run,openvpn --genkey --secret private/key.tlsauth)

private/clients/%.key: private/ca.key
	$(call docker_run,ovpn-cfgen build-key --key private/ca.key --cert private/ca.crt --workdir private/clients --name $(basename $@))

config/server.conf: private/server.key
	$(call docker_run,ovpn-cfgen server-config --ca private/ca.crt --cert private/server.crt --key private/server.key --dh private/dh.pem --tls-crypt private/key.tlsauth --output config/server.conf)

config/clients/%.ovpn: config/server.conf
	$(MAKE) private/clients/$(CLIENT_NAME).key && \
	$(call docker_run,ovpn-cfgen client-config --ca private/ca.crt --cert private/clients/$(CLIENT_NAME).crt --key private/clients/$(CLIENT_NAME).key --remote $(REMOTE_IP) --tls-crypt private/key.tlsauth --output config/clients/$$(basename $(CLIENT_NAME)).ovpn)

client: docker-build directories
	$(MAKE) "config/clients/$(CLIENT_NAME).ovpn"

config: docker-build directories config/server.conf
