# Install script for CentOS 8

**This script assumes the server is only used for aktionskarten!
Files will get removed without further checks!**


## How to 
1. Check out this repository on an CentOS 8 server.
   Don't forget to install git first: `yum install -y git`
   This script assumes git is already installed.
2. Get the tiles
2. Configure the script.
2. Run `install.sh`

## Getting the tiles
The tiles must be provided in [mbtiles](https://wiki.openstreetmap.org/wiki/MBTiles)
You can get the tiles for example from [maptiler](https://data.maptiler.com/downloads/planet/)

## Configuring the script
Adapt the variables in `config` accordingly.

You need to set an email-adress, a frontend, backend and tileserver URL.

Set the correct path for the mbtiles file you just downloaded.

## Techincal background

Running `install.sh` will setup a server with all necessary parts to run `aktionskarten`.

This script uses `docker-compose` to run the [backend](https://github.com/aktionskarten/backend) with the dependencies [tileserver-gl](https://github.com/aktionskarten/tileserver-gl), [redis](https://redis.io/) and a postgis database.

Docker-compose will be run by a systemd service `docker-compose@aktionskarten`.

Then [nginx](https://nginx.com) is configured as a reverse proxy, but also serves the [frontend](https://github.com/aktionskarten/frontend) as static content.

[Certbot](https://certbot.eff.org/) is used to generate SSL certificates to the given URLS.
