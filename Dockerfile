FROM ghcr.io/linuxserver/baseimage-alpine:3.15 as build-stage

ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    boost-dev \
    build-base \
    cmake \
    curl \
    git \
    grep \
    libtool \
    linux-headers \
    perl \
    pkgconf \
    python3-dev \
    re2c \
    icu-dev \
    libexecinfo-dev \
    openssl-dev \
    qt6-qtbase-dev \
    qt6-qttools-dev \
    qt6-qtsvg-dev \
    zlib-dev && \
  mkdir -p /build && \
  echo "**** build ninja ****" && \  
  git clone --shallow-submodules --recurse-submodules https://github.com/ninja-build/ninja.git ~/ninja && cd ~/ninja && \
  git checkout "$(git tag -l --sort=-v:refname "v*" | head -n 1)" && \
  cmake -Wno-dev -B build \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_PREFIX="/usr" && \
  cmake --build build && \
  cmake --install build && \ 
  echo "**** build libtorrent ****" && \  
  git clone --shallow-submodules --recurse-submodules https://github.com/arvidn/libtorrent.git ~/libtorrent && cd ~/libtorrent && \
  git checkout "$(git tag -l --sort=-v:refname "v2*" | head -n 1)" && \
  cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE="release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_LIBDIR="lib" \
    -D CMAKE_INSTALL_PREFIX="/usr" && \
  cmake --build build && \
  cmake --install build && \
  echo "**** build qbittorrent ****" && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION="release-"$(curl -s "https://raw.githubusercontent.com/qbittorrent/qBittorrent/HEAD/Changelog" | grep -Po '^\w{3} \w{3} \d{2} \d{4} - .* - \K(v\d+\.\d+\.\d+\.?\d?)$' | head -1 | cut -c2-); \
  fi && \
  git clone --shallow-submodules --recurse-submodules https://github.com/qbittorrent/qBittorrent.git ~/qbittorrent && cd ~/qbittorrent && \
  git checkout "$(git tag -l --sort=-v:refname "${QBITTORRENT_VERSION}" | head -n 1)" && \
  cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE="release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_CXX_STANDARD_LIBRARIES="/usr/lib/libexecinfo.so" \
    -D CMAKE_INSTALL_PREFIX="/build/usr" \
    -D GUI=OFF \
    -D QT6=ON && \
  cmake --build build && \
  cmake --install build && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /config/* \
    /tmp/*

FROM ghcr.io/linuxserver/baseimage-alpine:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

#copy build artifacts from build-stage
COPY --from=build-stage /build/usr/ /usr/
COPY --from=build-stage /usr/lib/libtorrent-rasterbar.so.* /usr/lib/

# install runtime packages and qbitorrent-cli
RUN \
  apk add -U --update --no-cache \
    p7zip \
    geoip \
    unzip \
    bash \
    curl \
    icu-libs\
    libexecinfo \
    openssl \
    python3 \
    qt6-qtbase \
    zlib && \
  apk add -U --upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main/ unrar && \
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
    /tmp/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config
