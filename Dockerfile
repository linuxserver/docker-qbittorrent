FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG QBITTORRENT_VER="3.3.16"
ARG RASTERBAR_VER="RC_1_0"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# copy patches
COPY patches/ /tmp/patches

# install build packages
RUN \
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
	qt5-qttools-dev && \

# install runtime packages
 apk add --no-cache \
	boost-system \
	boost-thread \
	ca-certificates \
	geoip \
	qt5-qtbase \
	unrar && \

# compile libtorrent rasterbar
 git clone https://github.com/arvidn/libtorrent.git /tmp/libtorrent && \
 cd /tmp/libtorrent && \
 git checkout ${RASTERBAR_VER} && \
 ./autotool.sh && \
 ./configure \
	--disable-debug \
	--enable-encryption \
	--prefix=/usr \
	--with-libgeoip=system && \
# attempt to set number of cores available for make to use
 set -ex && \
 CPU_CORES=$( < /proc/cpuinfo grep -c processor ) || echo "failed cpu look up" && \
 if echo $CPU_CORES | grep -E  -q '^[0-9]+$'; then \
	: ;\
 if [ "$CPU_CORES" -gt 7 ]; then \
	CPU_CORES=$(( CPU_CORES  - 3 )); \
 elif [ "$CPU_CORES" -gt 5 ]; then \
	CPU_CORES=$(( CPU_CORES  - 2 )); \
 elif [ "$CPU_CORES" -gt 3 ]; then \
	CPU_CORES=$(( CPU_CORES  - 1 )); fi \
 else CPU_CORES="1"; fi && \

 make -j $CPU_CORES && \
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
 make -j $CPU_CORES && \
 set +ex && \
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
