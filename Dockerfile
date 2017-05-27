FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG QBITTORRENT_VER="3.3.12"
ARG RASTERBAR_VER="1.0.11"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# copy patches
COPY patches/ /tmp/patches

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	boost-dev \
	cmake \
	curl \
	g++ \
	make \
	qt5-qttools-dev && \

# install runtime packages
 apk add --no-cache \
	boost-system \
	boost-thread \
	ca-certificates \
	qt5-qtbase && \

# compile libtorrent rasterbar
 RASTERBAR_VER2=${RASTERBAR_VER//./_} && \
 mkdir -p \
	/tmp/rasterbar-src && \
 curl -o \
 /tmp/rasterbar.tar.gz -L \
	"https://github.com/arvidn/libtorrent/releases/download/libtorrent-${RASTERBAR_VER2}/libtorrent-rasterbar-${RASTERBAR_VER}.tar.gz" && \
 tar xf \
 /tmp/rasterbar.tar.gz -C \
	/tmp/rasterbar-src --strip-components=1 && \
 cd /tmp/rasterbar-src && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \
 strip --strip-unneeded \
	/usr/lib/libtorrent-rasterbar.so* \
	/usr/lib/libtorrent-rasterbar.a* && \

# compile qbittorrent
 mkdir -p \
	/tmp/qbittorrent-src && \
 curl -o \
 /tmp/bittorrent.tar.gz -L \
	"https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VER}.tar.gz" && \
 tar xf \
 /tmp/bittorrent.tar.gz -C \
	/tmp/qbittorrent-src --strip-components=1 && \
 cd /tmp/qbittorrent-src/src/app && \
 patch -i /tmp/patches/main.patch && \
 cd /tmp/qbittorrent-src && \
 ./configure \
	--disable-gui \
	--prefix=/usr && \
 make && \
 make install && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config /downloads
