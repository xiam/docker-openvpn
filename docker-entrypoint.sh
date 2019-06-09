#!/bin/sh
set -e

mkdir -p config/ccd
mkdir -p config/clients
mkdir -p private/clients

eval "$@"

# attempt to fix ownership under Linux
usermod -u $HOST_UID openvpn
groupmod -g $HOST_GID openvpn

chown -R $HOST_UID:$HOST_GID /openvpn
