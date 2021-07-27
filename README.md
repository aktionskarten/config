# config

Check out this repository on an CentOS 8 server.
Don't forget to install git first: `yum install -y git`

Run `install.sh` to
* check out subrepositories (including styles for the tileserver)
* install docker
* install docker-compose
* set up docker-compose@.service
* configure tileserver-ng to run with docker-compose@.service

**You need to download the tile files into `config/tileserver-ng/tiles`**
Download them from [here](https://data.maptiler.com/downloads/planet/)  
Depending on the file you download you might want to update
`tileserver-ng/config.json`.

Afterwards you can start the tileserver with 
`systemctl start docker-compose@tileserver-ng`
