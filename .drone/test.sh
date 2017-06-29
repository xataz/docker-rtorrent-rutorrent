#!/bin/bash

## Variables
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
DATE_TEST=$(date +%Y%m%d)


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

## Test rtorrent-rutorrent
f_log INF "Run container ..."
docker run -d --name test_torrent_${DATE_TEST} xataz/rtorrent-rutorrent

f_log INF "Wait 10 sec ..."
sleep 10

docker ps | grep test_torrent_${DATE_TEST} 
if [ $? -ne 0 ]; then 
    f_log ERR "Run container failed"
    exit 1
else
    f_log SUC "Run container successful" 
fi

f_log INF "Test rutorrent ..."
docker exec -i test_torrent_${DATE_TEST} curl http://localhost:8080 | grep "404 Not Found"
if [ $? -ne 0 ]; then
    f_log SUC "rutorrent is ok" 
else
    f_log ERR "rutorrent is ko"
    exit 1
fi

f_log INT "Delete container ..."
docker rm -f test_torrent_${DATE_TEST}
if [ $? -ne 0 ]; then 
    f_log ERR "Delete container failed"
    exit 1
else
    f_log SUC "Delete container successful"
fi