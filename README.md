# RuTorrent Image

> This image is build and push with [drone.io](https://github.com/drone/drone), a circle-ci like self-hosted.
> If you don't trust, you can build yourself.


## Features
* Based on Alpine Linux.
* rTorrent and libtorrent are compiled from source.
* Provides by default a solid configuration.
* Filebot is included, and creates symlinks in /data/Media.
* No **ROOT** process.
* Persitance custom configuration for rutorrent and rtorrent.
* Add your own plugins and themes


## Tag available
* latest [(rutorrent/latest/Dockerfile)](https://github.com/xataz/dockerfiles/blob/master/rutorrent/latest/Dockerfile)
* latest-filebot, filebot [(rutorrent/latest-filebot/Dockerfile)](https://github.com/xataz/dockerfiles/blob/master/rutorrent/latest-filebot/Dockerfile)

## Description
What is [RuTorrent](https://github.com/Novik/ruTorrent) ?

ruTorrent is a front-end for the popular Bittorrent client rtorrent.
This project is released under the GPLv3 license, for more details, take a look at the LICENSE.md file in the source.

What is [rtorrent](https://github.com/rakshasa/rtorrent/) ?

rtorrent is the popular Bittorrent client.

**This image not contains root process**

## BUILD IMAGE
### Build arguments
* BUILD_CORES : Number of cpu's core for compile (default : empty for use all cores)
* MEDIAINFO_VER : Mediainfo version (default : 0.7.92.1)
* RTORRENT_VER : rtorrent version (default : 0.9.6)
* LIBTORRENT_VER : libtorrent version (default : 0.13.6)
* WITH_FILEBOT : Choose if install filebot (default : no)
* FILEBOT_VER : filebot version (default : 4.7.7)

### simple build
```shell
docker build -t xataz/rtorrent-rutorrent github.com/xataz/dockerfiles.git#master:rtorrent-rutorrent
```

### Build with arguments
```shell
docker build -t xataz/rtorrent-rutorrent:custom --build-arg WITH_FILEBOT=YES --build-arg RTORRENT_VER=0.9.4 github.com/xataz/dockerfiles.git#master:rtorrent-rutorrent
```


## Configuration
### Environments
* UID : Choose uid for launch rtorrent (default : 991)
* GID : Choose gid for launch rtorrent (default : 991)
* WEBROOT : (default : /)
* PORT_RTORRENT : (default : 45000)
* FILEBOT_RENAME_METHOD : Method for rename media (default : symlink)
* FILEBOT_RENAME_MOVIES : Regex for rename movies (default : "{n} ({y})")
* FILEBOT_RENAME_MUSICS : Regex for rename musics (default : "{n}/{fn}")
* FILEBOT_RENAME_SERIES : Regex for rename series (default : "{n}/Season {s.pad(2)}/{s00e00} - {t}")
* FILEBOT_RENAME_ANIMES : Regex for rename animes (default : "{n}/{e.pad(3)} - {t}")

### Volumes
* /data : Folder for download torrents
* /config : Folder for rtorrent and rutorrent configuration

#### data Folder tree
* /data/.watch : Rtorrent watch directory
* /data/.session : Rtorrent save statement here
* /data/torrents : Rtorrent download torrent here
* /data/Media : If filebot version, rtorrent create a symlink
* /config/rtorrent : Path of .rtorrent.rc
* /config/rutorrent/conf : Global configuration of rutorrent
* /config/rutorrent/share : rutorrent user configuration and cache
* /config/custom_plugins : Add your own plugins
* /config/custom_themes : Add your own themes

### Ports
* 8080
* $PORT_RTORRENT

## Usage
### Simple launch
```shell
docker run -dt -p 8080:8080 xataz/rtorrent-rutorrent
```
URI access : http://XX.XX.XX.XX:8080

### Advanced launch
Add custom plugin :
```shell
$ mkdir -p /docker/config/custom_plugins
$ cd /docker/config/custom_plugins
$ git clone https://github.com/Gyran/rutorrent-ratiocolor.git ./ratiocolor
```

Run container :
```shell
docker run -dt -p 80:8080 \
	  -v /docker/data:/data \
	  -v /docker/config:/config \
	  -e UID=1001 \
	  -e GID=1001 \
    -e WEBROOT=/rutorrent \
	xataz/rtorrent-rutorrent:filebot
```
URI access : http://XX.XX.XX.XX/rutorrent

## Contributing
Any contributions, are very welcome !