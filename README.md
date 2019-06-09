# OpenVPN in a container.

The goal of this project is to provide a hassle-free OpenVPN experience for
anyone, certificates and keys are managed within the container and both client
and server are configured with sane values. With `docker-openvpn` you can spin
up a new OpenVPN server in minutes with minimal effort.

## Running an OpenVPN server:

Generate a configuration file for OpenVPN server:

```
make config
# the command above will create the "config/server.conf" file
```

and then run OpenVPN:

```
docker run \
	--name openvpn \
	-p 0.0.0.0:1194:1194/udp \
	-v $PWD/config:/openvpn/config \
	-v $PWD/config/ccd:/openvpn/ccd \
	--cap-add=NET_ADMIN \
	--device /dev/net/tun:/dev/net/tun \
	-t xiam/openvpn \
	openvpn --config config/server.conf
```

Done.

## Registering clients

Use `make client` to create a `client.ovpn` file that you can feed to any major
OpenVPN client:

```
make client
# config/clients/client.ovpn
```

Each configuration file has its own private key.

You may create differerent configuration files for each client you want to
connect to the VPN:

```
CLIENT_NAME=fedora-x64 make client
# config/clients/fedora-x64.ovpn

CLIENT_NAME=macbook-work make client
# config/clients/macbook-work.ovpn
```

## Similar projects

* https://github.com/kylemanna/docker-openvpn
