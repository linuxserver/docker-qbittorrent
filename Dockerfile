FROM lsiobase/alpine:3.8 as buildstage
############## build stage ##############

# package versions
ARG QBITTORRENT_VER="4.1.3"
ARG RASTERBAR_VER="1.1.9"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	boost-dev \
	cmake \
	curl \
	file \
	g++ \
	geoip-dev \
	git \
	libtool \
	make \
	qt5-qttools-dev

RUN \
 echo "**** compile libtorrent rasterbar ****" && \
 git clone https://github.com/arvidn/libtorrent.git /tmp/libtorrent && \
 cd /tmp/libtorrent && \
 RASTERBAR_REALVER=${RASTERBAR_VER//./_} && \
 git checkout "libtorrent-${RASTERBAR_REALVER}" && \
 ./autotool.sh && \
 ./configure \
	--disable-debug \
	--enable-encryption \
	--prefix=/usr && \
 make && \
 make DESTDIR=/tmp/rasterbar-build install && \
 strip --strip-unneeded \
	/tmp/rasterbar-build/usr/lib/libtorrent-rasterbar.so* \
	/tmp/rasterbar-build/usr/lib/libtorrent-rasterbar.a* && \
 echo "**** copy rasterbar build to /usr for qbittorrent dependency ****" && \
 cp -pr /tmp/rasterbar-build/usr/* /usr/

RUN \
 echo "**** compile qbittorrent ****" && \
 mkdir -p \
	/tmp/qbittorrent-src && \
 curl -o \
 /tmp/bittorrent.tar.gz -L \
	"https://github.com/qbittorrent/qBittorrent/archive/release-${QBITTORRENT_VER}.tar.gz" && \
 tar xf \
 /tmp/bittorrent.tar.gz -C \
	/tmp/qbittorrent-src --strip-components=1 && \
 cd /tmp/qbittorrent-src && \
 ./configure \
	--disable-gui \
	--prefix=/usr && \
 make && \
 make INSTALL_ROOT=/tmp/qbittorrent-build install

############## runtime stage ##############

FROM lsiobase/alpine:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	boost-system \
	boost-thread \
	ca-certificates \
	geoip \
	qt5-qtbase \
	unrar

# copy files from build stage and local files
COPY --from=buildstage /tmp/qbittorrent-build/usr/ /usr/
COPY --from=buildstage /tmp/rasterbar-build/usr/ /usr/
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config /downloads
