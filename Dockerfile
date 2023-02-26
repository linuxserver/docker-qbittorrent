# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
ARG QBT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ARG UNRAR_VERSION=6.1.7
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    build-base && \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache \
    icu-libs \
    openssl1.1-compat \
    p7zip \
    python3 \
    qt6-qtbase-sqlite && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  install -v -m755 unrar /usr/bin && \
  echo "**** install qbittorrent ****" && \  
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sL "https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases" | \
    jq -r 'first(.[] | select(.prerelease == true) | .tag_name)'); \
  fi && \
  curl -o \
    /app/qbittorrent-nox -L \
    "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${QBITTORRENT_VERSION}/x86_64-qbittorrent-nox" && \
  chmod +x /app/qbittorrent-nox && \
  echo "***** install qbitorrent-cli ****" && \
  mkdir /qbt && \
  QBT_VERSION=$(curl -sL "https://api.github.com/repos/fedarovich/qbittorrent-cli/releases" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  curl -o \
    /tmp/qbt.tar.gz -L \
    "https://github.com/fedarovich/qbittorrent-cli/releases/download/${QBT_VERSION}/qbt-linux-alpine-x64-${QBT_VERSION:1}.tar.gz" && \
  tar xf \
    /tmp/qbt.tar.gz -C \
    /qbt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config
