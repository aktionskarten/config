#! /bin/bash

set -ex

SCRIPT_DIR=$(dirname $(realpath "$0"))
PWD_DIR=$(pwd)

# stop aktionskarten if already running
systemctl stop docker-compose@aktionskarten || true

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

# set up frontend
yum install -y npm

cd $SCRIPT_DIR/frontend
rm -rf node_modules
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="1" npm install --quiet

echo "API_ENDPOINT=https://backend.aktionskarten.org" > .env
npm run build

mkdir -p /var/www/aktionskarten-frontend/
mv dist/* /var/www/aktionskarten-frontend/
chown -R www:www /var/www/

# install nginx
yum install -y epel-release
yum install -y nginx certbot python3-certbot-nginx
cp nginx/*.conf /etc/nginx/conf.d/

systemctl enable nginx
systemctl restart nginx

certbot -n --agree-tos --email=kontakt@aktionskarten.org --nginx -d tiles.aktionskarten.org
certbot -n --nginx -d backend.aktionskarten.org
certbot -n --nginx -d frontend.aktionskarten.org

systemctl start docker-compose@aktionkarten

cd $PWD_DIR
