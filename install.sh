#! /bin/bash

set -ex

# we need to source config to use the variables in this script
source config

### get directories
SCRIPT_DIR=$(dirname $(realpath "$0"))

echo "Updating & Upgrading…"
apk update
apk upgrade --available


echo "Installing docker…"
# Install
apk add docker docker-compose
# Add to boot
rc-update add docker boot
# Start
service docker start


echo "Configuring docker…"
# Isolate containers with a user namespace
adduser -SDHs /sbin/nologin dockremap || true
addgroup -S dockremap || true
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f3):65536 >> /etc/subuid
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f4):65536 >> /etc/subgid
# copy daemon conf file
cp docker/daemon.json /etc/docker/daemon.json


echo "Installing nginx and configuring as reverse proxy…"
apk add nginx certbot certbot-nginx
adduser -D -g 'www' www || true
chown -R www:www /var/lib/nginx
rc-update add nginx default
# copy config files
cp nginx/* /etc/nginx/
# start nginx
rc-service nginx start


echo "Using certbot to get certificates…"
certbot -n --agree-tos --email=$EMAIL --nginx -d $TILES_URL --quiet
certbot -n --nginx -d $BACKEND_URL --quiet
certbot -n --nginx -d $FRONTEND_URL --quiet


echo "Configure openrc service script…"
cp openrc/dockerservice /etc/init.d/dockerservice
chmod +x /etc/init.d/dockerservice
mkdir -p /root/docker/aktionskarten
ln -s docker-compose/ /root/docker/aktionskarten
ln -s /etc/init.d/dockerservice /etc/init.d/dockerservice.aktionskarten
rc-update add dockerservice.aktionskarten default
rc-service dockerservice.aktionskarten start
