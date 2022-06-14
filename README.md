## !THIS SCRIPT IS STILL WORK IN PROGRESS AND SHOULD NOT YET BE USED!

# Install script for Alpine

**This script assumes the server is only used for aktionskarten!
Files will get removed without further checks!**


## How to 
1. Check out this repository on a server running alpine linux.  
    Don't forget to install git first: `apk add git`
2. Get the tiles
   See [Getting the tiles](#getting-the-tiles)
4. Configure the script.
5. Run `install.sh`

Or just have a look and set it up however you like ;)

## Getting the tiles
The tiles must be provided in [mbtiles](https://wiki.openstreetmap.org/wiki/MBTiles) format.  
You can get the tiles for example from [maptiler](https://data.maptiler.com/downloads/planet/)  
Place them in a folder and make sure to set the correct folder in the `config` file.

## Configuring the script
Adapt the variables in `config` accordingly.

You need to set an email-adress, a frontend, backend and tileserver URL.

Set the correct path for the `tiles` folder in which there are the mbtiles you just downloaded.

## Techincal background

Running `install.sh` will configure an alpine linux server with all necessary parts to run `aktionskarten`.

This script uses `docker-compose` to run the [frontend](https://github.com/aktionskarten/frontend) and [backend](https://github.com/aktionskarten/backend) with the dependencies [tileserver-gl](https://github.com/aktionskarten/tileserver-gl), [redis](https://redis.io/) and a postgis database.

Docker-compose will be run by a [OpenRC](https://wiki.alpinelinux.org/wiki/OpenRC) service named `dockerservice.aktionskarten`.

[nginx](https://nginx.com) is used as a reverse proxy.

[Certbot](https://certbot.eff.org/) is used to generate SSL certificates to the given URLS.
