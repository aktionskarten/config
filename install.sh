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
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd $SCRIPT_DIR

# checkout subrepos
git submodule update --init --recursive --remote

# set up systemctl docker script
mkdir -p /etc/docker/compose
ln -s $SCRIPT_DIR/server/docker-compose@.service /etc/systemd/system/docker-compose@.service
ln -s $SCRIPT_DIR/ /etc/docker/compose/aktionskarten

systemctl daemon-reload

# install nginx
yum install -y nginx
cp nginx/*.conf /etc/nginx/conf.d/

cd $PWD_DIR
