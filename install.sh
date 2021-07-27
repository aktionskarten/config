#! /bin/bash
SCRIPT_DIR = $(dirname "$0")
PWD_DIR = $(pwd)

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
git submodule update --init --recursive

# set up systemctl docker script
cd server
ln -s docker-compose@.service /etc/systemd/system/docker-compose@.service
mkdir -p /etc/docker/compose
cd ..

cd tileserver-gl
ln -s . /etc/docker/compose/tileserver-gl

cd $PWD_DIR
