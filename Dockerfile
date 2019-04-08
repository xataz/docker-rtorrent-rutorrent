FROM alpine:3.8

ARG BUILD_CORES
ARG MEDIAINFO_VER=0.7.99
ARG RTORRENT_VER=v0.9.7
ARG LIBTORRENT_VER=v0.13.7
ARG LIBZEN_VER=0.4.31
ARG GEOIP_VER=1.1.1

ENV UID=991 \
    GID=991 \
    WEBROOT=/ \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    DISABLE_PERM_DATA=false \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

LABEL Description="rutorrent based on alpine" \
      tags="latest" \
      maintainer="xataz <https://github.com/xataz>" \
      mediainfo_version="${MEDIAINFO_VER}" \
      libtorrent_version="${LIBTORRENT_VER}" \
      rtorrent_version="${RTORRENT_VER}" \
      libzen_version="${LIBZEN_VER}" \
      build_ver="201904081410"

RUN export BUILD_DEPS="build-base \
                        libtool \
                        automake \
                        autoconf \
                        wget \
                        libressl-dev \
                        ncurses-dev \
                        curl-dev \
                        zlib-dev \
                        libnl3-dev \
                        libsigc++-dev \
                        linux-headers \
			py-pip" \
    ## Download Package
    && if [ "$RTORRENT_VER" == "0.9.6" ]; then CPPUNIT_VER="==1.13.2-r1"; fi \
    && apk upgrade --no-cache \
    && apk add -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main --no-cache ${BUILD_DEPS} \
                ffmpeg \
                libnl3 \
                ca-certificates \
                gzip \
                zip \
                unrar \
                curl \
                c-ares \
                s6 \
                geoip \
                geoip-dev \
                su-exec \
                nginx \
                php7 \
                php7-fpm \
                php7-json \
                php7-opcache \
                php7-apcu \
                php7-mbstring \
                php7-ctype \
                php7-pear \
                php7-dev \
		php7-sockets \
		php7-phar \
                libressl \
                file \
                findutils \
                tar \
                xz \
                screen \
                findutils \
                bzip2 \
                bash \
                git \
                sox \
		python \
                cppunit-dev${CPPUNIT_VER} \
                cppunit${CPPUNIT_VER} \
    ## Download Sources
    && git clone https://github.com/esmil/mktorrent /tmp/mktorrent \
    && git clone https://github.com/mirror/xmlrpc-c.git /tmp/xmlrpc-c \
    && git clone -b ${LIBTORRENT_VER} https://github.com/rakshasa/libtorrent.git /tmp/libtorrent \
    && git clone -b ${RTORRENT_VER} https://github.com/rakshasa/rtorrent.git /tmp/rtorrent \
    && wget http://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VER}/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz -O /tmp/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    && wget http://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VER}/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz -O /tmp/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    && wget http://downloads.sourceforge.net/zenlib/libzen_${LIBZEN_VER}.tar.gz -O /tmp/libzen_${LIBZEN_VER}.tar.gz \
    && cd /tmp \
    && tar xzf libzen_${LIBZEN_VER}.tar.gz \
    && tar xzf MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    && tar xzf MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz \
    ## Compile ZenLib
    && cd /tmp/ZenLib/Project/GNU/Library \
    && ./autogen \
    && ./configure --prefix=/usr/local \
                    --enable-shared \
                    --disable-static \
    && make && make install \
    ## Compile mktorrent
    && cd /tmp/mktorrent \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile Mediainfo
    && cd  /tmp/MediaInfo_DLL_GNU_FromSource \
    && ./SO_Compile.sh \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library \
    && make install \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource \
    && ./CLI_Compile.sh \
    && cd /tmp/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI \
    && make install \
    ## Compile xmlrpc-c
    && cd /tmp/xmlrpc-c/stable \
    && ./configure \
    && make -j ${NB_CORES} \
    && make install \
    ## Compile libtorrent
    && cd /tmp/libtorrent \
    && ./autogen.sh \
    && ./configure \
        --disable-debug \
		--disable-instrumentation \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Compile rtorrent
    && cd /tmp/rtorrent \
    && ./autogen.sh \
    && ./configure \
        --enable-ipv6 \
		--disable-debug \
		--with-xmlrpc-c \
    && make -j ${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && make install \
    ## Install Rutorrent
    && mkdir -p /var/www \
    && git clone https://github.com/Novik/ruTorrent.git /var/www/html/rutorrent \
    && git clone https://github.com/nelu/rutorrent-thirdparty-plugins /tmp/rutorrent-thirdparty-plugins \
    && git clone https://github.com/mcrapet/plowshare /tmp/plowshare \
    && git clone https://github.com/xombiemp/rutorrentMobile.git /var/www/html/rutorrent/plugins/mobile \    
    && git clone https://github.com/Phlooo/ruTorrent-MaterialDesign.git /var/www/html/rutorrent/plugins/theme/themes/materialdesign \
    && git clone https://github.com/Micdu70/geoip2-rutorrent /var/www/html/rutorrent/plugins/geoip2 \
    && rm -rf /var/www/html/rutorrent/plugins/geoip \
    && sed -i "s/'mkdir'.*$/'mkdir',/" /tmp/rutorrent-thirdparty-plugins/filemanager/flm.class.php \
    && sed -i 's#.*/usr/bin/rar.*##' /tmp/rutorrent-thirdparty-plugins/filemanager/conf.php \
    && mv /tmp/rutorrent-thirdparty-plugins/* /var/www/html/rutorrent/plugins/ \
    && mv /var/www/html/rutorrent /var/www/html/torrent \
    ## Install plowshare
    && cd /tmp/plowshare \
    && make \
    ## Install geoip files
    && mkdir -p /usr/share/GeoIP \
    && cd /usr/share/GeoIP \
    && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
    && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
    && tar xzf GeoLite2-City.tar.gz \
    && tar xzf GeoLite2-Country.tar.gz \
    && rm -f *.tar.gz \
    && mv GeoLite2-*/*.mmdb . \
    && cp *.mmdb /var/www/html/torrent/plugins/geoip2/database/ \
    && pecl install geoip-${GEOIP_VER} \
    && chmod +x /usr/lib/php7/modules/geoip.so \
    ## Install cfscrape
    && pip install cfscrape \
    ## cleanup
    && strip -s /usr/local/bin/rtorrent \
    && strip -s /usr/local/bin/mktorrent \
    && strip -s /usr/local/bin/mediainfo \
    && apk del -X http://dl-cdn.alpinelinux.org/alpine/v3.6/main --no-cache ${BUILD_DEPS} cppunit-dev \
    && rm -rf /tmp/*

ARG WITH_FILEBOT=NO
ARG FILEBOT_VER=4.7.9
ARG CHROMAPRINT_VER=1.4.3

ENV filebot_version="${FILEBOT_VER}" \
      chromaprint_ver="${CHROMAPRINT_VER}"

ENV FILEBOT_RENAME_METHOD="symlink" \
    FILEBOT_RENAME_MOVIES="{n} ({y})" \
    FILEBOT_RENAME_SERIES="{n}/Season {s.pad(2)}/{s00e00} - {t}" \
    FILEBOT_RENAME_ANIMES="{n}/{e.pad(3)} - {t}" \
    FILEBOT_RENAME_MUSICS="{n}/{fn}" \
    FILEBOT_LANG="fr" \
    FILEBOT_CONFLICT=skip

RUN if [ "${WITH_FILEBOT}" == "YES" ]; then \
        apk add --no-cache openjdk8-jre java-jna-native binutils wget nss \
        && mkdir /filebot \
        && cd /filebot \
        && wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz -O /filebot/filebot.tar.xz \
        && tar xJf filebot.tar.xz \
        && ln -sf /usr/local/lib/libzen.so.0.0.0 /filebot/lib/x86_64/libzen.so \
        && ln -sf /usr/local/lib/libmediainfo.so.0.0.0 /filebot/lib/x86_64/libmediainfo.so \
        && wget https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VER}/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
        && tar xvf chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
        && mv chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64/fpcalc /usr/local/bin \
        && strip -s /usr/local/bin/fpcalc \
        && apk del --no-cache binutils wget \
        && rm -rf /tmp/* \
                  /filebot/FileBot_${FILEBOT_VER}-portable.tar.xz \
                  /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz\
                  /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64 \
    ;fi

COPY rootfs /
VOLUME /data /config
EXPOSE 8080
RUN chmod +x /usr/local/bin/startup

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
