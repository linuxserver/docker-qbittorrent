[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!
* [Podcast](https://anchor.fm/linuxserverio) - on hiatus. Coming back soon (late 2018).

# PSA: Changes are happening

From August 2018 onwards, Linuxserver are in the midst of switching to a new CI platform which will enable us to build and release multiple architectures under a single repo. To this end, existing images for `arm64` and `armhf` builds are being deprecated. They are replaced by a manifest file in each container which automatically pulls the correct image for your architecture. You'll also be able to pull based on a specific architecture tag.

TLDR: Multi-arch support is changing from multiple repos to one repo per container image.

# [linuxserver/qbittorrent](https://github.com/linuxserver/docker-qbittorrent)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/qbittorrent.svg)](https://microbadger.com/images/linuxserver/qbittorrent "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/qbittorrent.svg)](https://microbadger.com/images/linuxserver/qbittorrent "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/qbittorrent.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/qbittorrent.svg)

The [Qbittorrent](https://www.qbittorrent.org/) project aims to provide an open-source software alternative to µTorrent. qBittorrent is based on the Qt toolkit and libtorrent-rasterbar library.

[![qbittorrent](https://github.com/linuxserver/docker-templates/raw/master/linuxserver.io/img/qbittorrent-icon.png)](https://www.qbittorrent.org/)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list). 

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v6-latest |

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=qbittorrent \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e UMASK_SET=022 \
  -e WEBUI_PORT=8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -p 8080:8080 \
  -v </path/to/appdata/config>:/config \
  --restart unless-stopped \
  linuxserver/qbittorrent
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  qbittorrent:
    image: linuxserver/qbittorrent
    container_name: qbittorrent
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=Europe/London
      - UMASK_SET=022
      - WEBUI_PORT=8080
    volumes:
      - </path/to/appdata/config>:/config
    ports:
      - 6881:6881
      - 6881:6881/udp
      - 8080:8080
    mem_limit: 4096m
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 6881` | tcp connection port |
| `-p 6881/udp` | udp connection port |
| `-p 8080` | http gui |
| `-e PUID=1001` | for UserID - see below for explanation |
| `-e PGID=1001` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London |
| `-e UMASK_SET=022` | for umask setting of qbittorrent, optional , default if left unset is 022 |
| `-e WEBUI_PORT=8080` | for changing the port of the webui, see below for explanation |
| `-v /config` | Contains all relevant configuration files. |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

&nbsp;
## Application Setup

The webui is at `<your-ip>:8080` and the default username/password is `admin/adminadmin`.  

Change username/password via the webui in the webui section of settings.  


### WEBUI_PORT variable

Due to issues with CSRF and port mapping, should you require to alter the port for the webui you need to change both sides of the -p 8080 switch AND set the WEBUI_PORT variable to the new port.  

For example, to set the port to 8090 you need to set -p 8090:8090 and -e WEBUI_PORT=8090  

This should alleviate the "white screen" issue.  

If you have no webui , check the file /config/qBittorrent/qBittorrent.conf  

edit or add the following lines  

```
WebUI\Address=*

WebUI\ServerDomains=*
```



## Support Info

* Shell access whilst the container is running: `docker exec -it qbittorrent /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f qbittorrent`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' qbittorrent`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/qbittorrent`

## Versions

* **14.01.19:** - Rebase to Ubuntu, add multi arch and pipeline logic.
* **25.09.18:** - Use buildstage type build, bump qbitorrent to 4.1.3.
* **14.08.18:** - Rebase to alpine 3.8, bump libtorrent to 1.1.9 and qbitorrent to 4.1.2.
* **08.06.18:** - Bump qbitorrent to 4.1.1.
* **26.04.18:** - Bump libtorrent to 1.1.7.
* **02.03.18:** - Bump qbitorrent to 4.0.4 and libtorrent to 1.1.6.
* **02.01.18:** - Deprecate cpu_core routine lack of scaling.
* **19.12.17:** - Update to v4.0.3.
* **09.02.17:** - Rebase to alpine 3.7
* **01.12.17:** - Update to v4.0.2.
* **27.11.17:** - Update to v4 and use cpu_core routine to speed up builds.
* **16.09.17:** - Bump to 3.3.16, Add WEBUI_PORT variable and notes to README to allow changing port of webui.
* **01.08.17:** - Initial Release.
* **12.02.18:** - Initial Release.
