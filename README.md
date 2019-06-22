# OpenVPN in a container.

The goal of this project is to provide a hassle-free OpenVPN experience for
anyone, certificates and keys are managed within the container and both client
and server are configured with sane values. With `docker-openvpn` you can spin
up a new OpenVPN server in minutes with minimal effort.

## Automatic deployment (with ansible)

[Install](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
Ansible 2.8+ in your localhost.

```
ansible-playbook --version
# ansible-playbook 2.8.1
#   config file = /etc/ansible/ansible.cfg
```

Make sure you have root access to a remote host (like 192.168.8.7) and [install
docker on it](https://docs.docker.com/install/).

Clone this repo:

```
cd ~/projects
git clone https://github.com/xiam/docker-openvpn.git
```

Get into the `docker-openvpn` directory and run `make deploy` using a
`REMOTE_IP` env var that matches the IP of the remote host:

```
cd docker-openvpn
REMOTE_IP=192.168.8.7 make deploy
```

Wait a few seconds while the OpenVPN server gets configured.

Once the command finishes, you'll have a `client.ovpn` file that you can use it
to connect to your shiny new OpenVPN server:

```
openvpn --config client.ovpn
```

For each client you want to add set a `CLIENT_NAME` env var, don't forget
to set `REMOTE_IP` as well:

```
CLIENT_NAME=mba13 REMOTE_IP=192.168.8.7 make deploy
# cat mba13.ovpn
```

Enjoy!

## Manual deployment (with make)

Generate a configuration file for OpenVPN server:

```
make config
# the command above will create the "config/server.conf" file
```

and then run OpenVPN:

```
docker run \
  -d \
  --name openvpn \
  -p 0.0.0.0:1194:1194/udp \
  -v $PWD/config:/openvpn/config \
  -v $PWD/config/ccd:/openvpn/ccd \
  --restart always \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  -t xiam/openvpn \
  openvpn --config config/server.conf
```

Use `make client` to create a `client.ovpn` file that you can feed to any major
OpenVPN client:

```
make client
# config/clients/client.ovpn
```

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
