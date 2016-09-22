#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: allow-dns-records.sh DOMAIN PORT PROTO"
	exit
fi

DOMAIN=$1
PORT=$2
PROTO=$3

for i in $(dig $DOMAIN any | grep "`printf 'IN\tA\t'`" | awk '{print $5}'); do echo "-A OUTPUT -d $i/32 -p $PROTO -m $PROTO --dport $PORT -j ACCEPT"; done
