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


# Push rtorrent-rutorrent
for tag in latest filebot latest-filebot stable stable-filebot filebot-stable; do
    f_log INF "Push xataz/rtorrent-rutorrent:$tag"
    docker push xataz/rtorrent-rutorrent:$tag
    if [ $? -ne 0 ]; then
        f_log ERR "Push xataz/rtorrent-rutorrent:$tag failed"
        exit 1
    else
        f_log SUC "Push xataz/rtorrent-rutorrent:$tag successful"
    fi
done