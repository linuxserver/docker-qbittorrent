FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
ARG QBT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ARG QBT_VERSION=1.7
ARG UNRAR_VERSION=6.1.4
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    make \
    g++ \
    gcc && \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache \
    bash \
    curl \
    icu-libs \
    libstdc++ \
    openssl \
    p7zip \
    python3 && \
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
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    qbittorrent-nox==${QBITTORRENT_VERSION} && \
  echo "***** install qbitorrent-cli ****" && \
  mkdir /qbt && \
  curl -L \
    -o /tmp/qbt.tar.gz \
    "https://github.com/linuxserver/docker-qbittorrent/releases/download/qbt-${QBT_VERSION}/qbt.tar.gz" && \
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
