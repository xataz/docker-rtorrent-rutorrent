#!/bin/bash

## Variables
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"


## Functions
f_log() {
    TYPE=$1
    MSG=$2

    if [ "${TYPE}" == "ERR" ]; then
        COLOR=${CRED}
    elif [ "${TYPE}" == "INF" ]; then
        COLOR=${CBLUE}
    elif [ "${TYPE}" == "WRN" ]; then
        COLOR=${CYELLOW}
    elif [ "${TYPE}" == "SUC" ]; then
        COLOR=${CGREEN}
    else
        COLOR=${CEND}
    fi

    echo -e "${COLOR}=${TYPE}= $TIMENOW : ${MSG}${CEND}"
}


# Build rtorrent-rutorrent
f_log INF "Build xataz/rtorrent-rutorrent:latest ..."
docker build -t xataz/rtorrent-rutorrent:latest . > /tmp/build.log 2>&1
if [ $? -eq 0 ]; then
    f_log SUC "Build xataz/rtorrent-rutorrent:latest successful"
else
    f_log ERR "Build xataz/rtorrent-rutorrent:latest failed"
    cat /tmp/build.log
    exit 1
fi

f_log INF "Build xataz/rtorrent-rutorrent:stable ..."
docker build --build-arg RTORRENT_VER=0.9.6 --build-arg LIBTORRENT_VER=0.13.6 -t xataz/rtorrent-rutorrent:stable .
if [ $? -eq 0 ]; then
    f_log SUC "Build xataz/rtorrent-rutorrent:stable successful"
else
    f_log ERR "Build xataz/rtorrent-rutorrent:stable failed"
    cat /tmp/build.log
    exit 1
fi

f_log INF "Build xataz/rtorrent-rutorrent:filebot ..."
docker build --build-arg WITH_FILEBOT=YES -t xataz/rtorrent-rutorrent:filebot . > /tmp/build.log 2>&1
if [ $? -eq 0 ]; then
    f_log SUC "Build xataz/rtorrent-rutorrent:filebot successful"
    docker tag xataz/rtorrent-rutorrent:filebot xataz/rtorrent-rutorrent:latest-filebot
else
    f_log ERR "Build xataz/rtorrent-rutorrent:filebot failed"
    cat /tmp/build.log
    exit 1
fi

f_log INF "Build xataz/rtorrent-rutorrent:filebot-stable ..."
docker build --build-arg WITH_FILEBOT=YES \
            --build-arg RTORRENT_VER=0.9.6 \
            --build-arg LIBTORRENT_VER=0.13.6 \
            -t xataz/rtorrent-rutorrent:filebot-stable . > /tmp/build.log 2>&1
if [ $? -eq 0 ]; then
    f_log SUC "Build xataz/rtorrent-rutorrent:filebot-stable successful"
    docker tag xataz/rtorrent-rutorrent:filebot-stable xataz/rtorrent-rutorrent:stable-filebot
else
    f_log ERR "Build xataz/rtorrent-rutorrent:filebot-stable failed"
    cat /tmp/build.log
    exit 1
fi