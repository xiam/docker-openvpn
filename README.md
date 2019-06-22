# OpenVPN in a container

The goal of this project is to provide a hassle-free OpenVPN experience for
anyone, certificates and keys are managed within the container and both client
and server are configured with sane values. With `docker-openvpn` you can spin
up a new OpenVPN server in less than a minute with minimal effort.

## Automatic deployment (with ansible)

[Install Ansible 2.8+](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
in your localhost.

```
ansible-playbook --version
# ansible-playbook 2.8.1
#   config file = /etc/ansible/ansible.cfg
```

Make sure you have root access to a remote host (like `192.168.8.7`) and [install
docker on it](https://docs.docker.com/install/).

Clone this repo:

```
cd ~/projects
git clone https://github.com/xiam/docker-openvpn.git
```

Get into the `docker-openvpn` directory and run `make deploy`,
pass a `REMOTE_HOST` environment variable that matches the IP/FQDN
of the remote server:

```
cd docker-openvpn
REMOTE_HOST=192.168.8.7 make deploy
```

Wait a few seconds while your OpenVPN server gets configured.

Once the command finishes, you'll have a `client.ovpn` file on your localhost
that you can use to connect to your shiny new OpenVPN server:

```
openvpn --config client.ovpn
```

Check if you exit IP changed after connecting to the VPN:

```
curl ifconfig.co
# 192.168.8.7
```

For each client you want to add set a `CLIENT_NAME` env var and
run `make deploy` again, don't forget to set `REMOTE_HOST` as
well:

```
CLIENT_NAME=mba13 REMOTE_HOST=192.168.8.7 make deploy
# cat mba13.ovpn
```

Enjoy!

## Similar projects

* https://github.com/kylemanna/docker-openvpn
