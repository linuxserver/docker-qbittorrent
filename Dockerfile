FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
ARG QBT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  apk add -U --update --no-cache \
    bash \
    curl && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    qbittorrent-nox==${QBITTORRENT_VERSION} && \
  echo "***** install qbitorrent-cli ****" && \
  if [ -z ${QBT_VERSION+x} ]; then \
    QBT_VERSION=$(curl -sX GET "https://api.github.com/repos/ludviglundgren/qbittorrent-cli/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/qbt.tar.gz -L \
    "https://github.com/ludviglundgren/qbittorrent-cli/releases/download/${QBT_VERSION}/qbittorrent-cli_$(echo $QBT_VERSION | cut -c2-)_linux_amd64.tar.gz" && \
  tar xzf \
    /tmp/qbt.tar.gz -C \
    /tmp && \
    mv /tmp/qbt /usr/bin && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config
