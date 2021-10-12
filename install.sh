#! /bin/bash

set -ex

SCRIPT_DIR=$(dirname $(realpath "$0"))
PWD_DIR=$(pwd)

# install docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker

# install docker-compose
yum install -y curl

rm -f /usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd $SCRIPT_DIR

# checkout subrepos
git pull --recurse-submodules
git submodule update --init --recursive

# set up systemctl docker script
mkdir -p /etc/docker/compose
ln -sf $SCRIPT_DIR/server/docker-compose@.service /etc/systemd/system/docker-compose@.service
ln -sf $SCRIPT_DIR/ /etc/docker/compose/aktionskarten

systemctl daemon-reload

# install nginx
yum install -y epel-release
yum install -y nginx certbot python3-certbot-nginx
cp nginx/*.conf /etc/nginx/conf.d/

certbot -n --agree-tos --email=kontakt@aktionskarten.org --nginx -d tiles.aktionskarten.org
certbot -n --nginx -d backend.aktionskarten.org


systemctl enable nginx
systemctl start nginx


cd $PWD_DIR
