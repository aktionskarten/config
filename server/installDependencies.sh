#! /bin/bash
# install git
yum install git

# install docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker

# install docker-compose
yum install curl
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# clone git repo
git clone https://github.com/aktionskarten/config.git
cd config
git submodule update --init --recursive

# set up systemctl docker script
cd server
ln -s docker-compose@.service /etc/systemd/system/docker-compose@.service
mkdir -p /etc/docker/compose
cd ..

cd tileserver-gl
ln -s . /etc/docker/compose/tileserver-gl

systemctl start docker-compose@tileserver-gl


