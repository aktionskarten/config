#! /bin/bash

set -ex

CERTBOT_EMAIL="kontakt@aktionskarten.org"

BACKEND_URL="backend.aktionskarten.org"
TILES_URL="tiles.aktionskarten.org"
FRONTEND_URL="frontend.aktionskarten.org"


### get directories
SCRIPT_DIR=$(dirname $(realpath "$0"))

### stop aktionskarten if already running
systemctl stop docker-compose@aktionskarten || true

### install docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker


### install docker-compose
yum install -y curl
rm -f /usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

### checkout subrepos
git pull --recurse-submodules
git submodule update --init --recursive

### set up systemctl docker script
mkdir -p /etc/docker/compose
cp $SCRIPT_DIR/server/docker-compose@.service /etc/systemd/system/docker-compose@.service
ln -s $SCRIPT_DIR /etc/docker/compose/aktionskarten

### set up frontend
cd $SCRIPT_DIR/frontend
yum install -y npm
rm -rf node_modules
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="1" npm install --quiet

echo "API_ENDPOINT=https://$BACKEND_URL" > .env
npm run --silent build

mkdir -p /var/www/aktionskarten-frontend/
mv dist/* /var/www/aktionskarten-frontend/
chown -R nginx:nginx /var/www/

cd $SCRIPT_DIR

### install nginx
yum install -y epel-release
yum install -y nginx certbot python3-certbot-nginx
cp nginx/*.conf /etc/nginx/conf.d/

systemctl enable nginx
systemctl restart nginx

certbot -n --agree-tos --email=$CERTBOT_EMAIL --nginx -d $TILES_URL
certbot -n --nginx -d $BACKEND_URL
certbot -n --nginx -d $FRONTEND_URL

systemctl daemon-reload
systemctl start docker-compose@aktionkarten

