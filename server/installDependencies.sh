#! /bin/bash
apk add git
apk add docker
# docker compose dependencies
apk add py-pip python3-dev libffi-dev openssl-dev gcc libc-dev rust cargo make
# fetch docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# make docker-compose executable
chmod +x /usr/local/bin/docker-compose