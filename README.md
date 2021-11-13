## !THIS SCRIPT IS STILL WORK IN PROGRESS AND SHOULD NOT YET BE USED!

# Install script for CentOS 8

**This script assumes the server is only used for aktionskarten!
Files will get removed without further checks!**


## How to 
1. Check out this repository on an CentOS 8 server.
   Don't forget to install git first: `yum install -y git`
   This script assumes git is already installed.
2. Get the tiles
3. Configure the script.
4. Run `install.sh`

Or just have a look and set it up however you like ;)

## Getting the tiles
The tiles must be provided in [mbtiles](https://wiki.openstreetmap.org/wiki/MBTiles)  
You can get the tiles for example from [maptiler](https://data.maptiler.com/downloads/planet/)  
Place them in a `tiles` folder.

## Configuring the script
Adapt the variables in `config` accordingly.

You need to set an email-adress, a frontend, backend and tileserver URL.

Set the correct path for the `files` folder in which there are the mbtiles you just downloaded.

## Techincal background

Running `install.sh` will configure a CentOS 8 server with all necessary parts to run `aktionskarten`.

This script uses `docker-compose` to run the [backend](https://github.com/aktionskarten/backend) with the dependencies [tileserver-gl](https://github.com/aktionskarten/tileserver-gl), [redis](https://redis.io/) and a postgis database.

Docker-compose will be run by a systemd service `docker-compose@aktionskarten`.

Then [nginx](https://nginx.com) is configured as a reverse proxy, but also serves the [frontend](https://github.com/aktionskarten/frontend) as static content.

[Certbot](https://certbot.eff.org/) is used to generate SSL certificates to the given URLS.

`dnf-automatic` is configured to automatically install updates and keep the server up to date. You will get emails to the `EMAIL` adress in the configuration from `root@${BACKEND_URL}`.
