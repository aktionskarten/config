#! /bin/bash

set -ex

CERTBOT_EMAIL="kontakt@aktionskarten.org"

BACKEND_URL="backend.aktionskarten.org"
TILES_URL="tiles.aktionskarten.org"
FRONTEND_URL="frontend.aktionskarten.org"


### get directories
SCRIPT_DIR=$(dirname $(realpath "$0"))

### stop aktionskarten if already running
systemctl stop nginx || true
systemctl stop docker-compose@aktionskarten || true

### install docker
yum install -y yum-utils -q
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo -q

yum install -y docker-ce docker-ce-cli containerd.io -q
systemctl start docker
systemctl enable docker


### install docker-compose
yum install -y curl -q
rm -f /usr/local/bin/docker-compose
curl -sS -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

### checkout subrepos
git submodule update --init --recursive --quiet
git pull --recurse-submodules --quiet

### set up systemctl docker script
mkdir -p /etc/docker/compose
cp $SCRIPT_DIR/server/docker-compose@.service /etc/systemd/system/docker-compose@.service
ln -sfn $SCRIPT_DIR /etc/docker/compose/aktionskarten
systemctl daemon-reload

### set up frontend
cd $SCRIPT_DIR/frontend
yum install -y npm -q
rm -rf node_modules
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="1" npm install &> /dev/null

echo "API_ENDPOINT=https://$BACKEND_URL" > .env
npm run build &> /dev/null

mkdir -p /var/www/aktionskarten-frontend/
rm -rf /var/www/aktionskarten-frontend/*
mv dist/* /var/www/aktionskarten-frontend/
chown -R nginx:nginx /var/www/

cd $SCRIPT_DIR

### install nginx
yum install -y epel-release -q
yum install -y nginx certbot python3-certbot-nginx -q
cp nginx/*.conf /etc/nginx/conf.d/

systemctl enable nginx
systemctl start nginx

certbot -n --agree-tos --email=$CERTBOT_EMAIL --nginx -d $TILES_URL --quiet
certbot -n --nginx -d $BACKEND_URL --quiet
certbot -n --nginx -d $FRONTEND_URL --quiet

systemctl start docker-compose@aktionskarten

