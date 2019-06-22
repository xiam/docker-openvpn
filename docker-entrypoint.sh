#!/bin/sh
set -e

touch ipp.txt
mkdir -p ccd

mkdir -p config/clients
mkdir -p private/clients

eval "$@"

# attempt to fix ownership under Linux
usermod -u $HOST_UID -d /openvpn openvpn
groupmod -g $HOST_GID openvpn

chown -R $HOST_UID:$HOST_GID /openvpn
