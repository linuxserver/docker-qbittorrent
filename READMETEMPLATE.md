[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/
[appurl]: https://www.qbittorrent.org
[hub]: https://hub.docker.com/r/linuxserver/qbittorrent/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/qbittorrent
[![](https://images.microbadger.com/badges/version/linuxserver/qbittorrent.svg)](https://microbadger.com/images/linuxserver/qbittorrent "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/linuxserver/qbittorrent.svg)](https://microbadger.com/images/linuxserver/qbittorrent "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/qbittorrent.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/qbittorrent.svg)][hub][![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Builders/x86-64/x86-64-qbittorrent)](https://ci.linuxserver.io/job/Docker-Builders/job/x86-64/job/x86-64-qbittorrent/)

The [qBittorrent][appurl] project aims to provide an open-source software alternative to µTorrent.
qBittorrent is based on the Qt toolkit and libtorrent-rasterbar library.

[![qbittorrent](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/qbittorrent-icon.png)][appurl]

## Usage

```
docker create \
  --name=qbittorrent \
  -v <path to config>:/config \
  -v <path to downloads>:/downloads \
  -e PGID=<gid> -e PUID=<uid>  \
  -e UMASK_SET=<022> \
  -e TZ=<timezone> \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -p 8080:8080 \
  linuxserver/qbittorrent
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `-p 6881` - the port(s)
* `-p 6881/udp` - the port(s)
* `-p 8080` - the port(s)
* `-v /config` - where qbittorrent should store its config files
* `-v /downloads` - path to downloads
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e UMASK_SET` for umask setting of qbittorrent, *optional* , default if left unset is 022. 
* `-e TZ` for timezone information, eg Europe/London

It is based on alpine linux with s6 overlay, for shell access whilst the container is running do `docker exec -it qbittorrent /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

The webui is at `<your-ip>:8080` and the default username/password is `admin/adminadmin`.

Change username/password via the webui in the webui section of settings.


## Info

* Shell access whilst the container is running: `docker exec -it qbittorrent /bin/bash`

To monitor the logs of the container in realtime: `docker logs -f qbittorrent`

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' qbittorrent`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/qbittorrent`

## Versions

+ **13.07.17:** Initial Release.
