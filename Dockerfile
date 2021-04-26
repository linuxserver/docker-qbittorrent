FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# add repo and install qbitorrent
RUN \
  echo "***** add qbitorrent repositories ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg \
    python3 && \
  curl -s https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/gpg.F8756541ADDA2B7D.key | apt-key add - && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && \
  echo "deb http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb-src http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/deb/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "**** install packages ****" && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sX GET http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/focal/main/binary-amd64/Packages.gz | gunzip -c \
    |grep -A 7 -m 1 "Package: qbittorrent-nox" | awk -F ": " '/Version/{print $2;exit}');\
  fi && \
  apt-get update && \
  apt-get install -y \
    p7zip-full \
    qbittorrent-cli \
    qbittorrent-nox=${QBITTORRENT_VERSION} \
    unrar \
    geoip-bin \
    unzip && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config
