#!/bin/bash
URL="https://nordvpn.com/ovpn/"
CERTS_URL="https://downloads.nordcdn.com/configs/archives/certificates/servers.zip"
TPL="template"
TMP="tmp"
SERVERS_SRC="$TPL/servers.html"
SERVERS_DST="$TPL/servers.csv"
CERTS_SRC="$TPL/certs.zip"

mkdir -p $TPL
curl -L $URL >$SERVERS_SRC
curl -L $CERTS_URL >$CERTS_SRC
rm -rf $TMP
unzip -q $CERTS_SRC -d $TMP

# id,country,area,num,hostname
grep -E '<span class="mr-2">.*nordvpn.com</span>' $SERVERS_SRC | sed -E 's/.*<span class="mr-2">([A-z]+)(-)?([A-z]+)?([0-9]+)\.nordvpn\.com<.*$/\1\2\3\4,\1,\3,\4,\1\2\3\4.nordvpn.com/' >$SERVERS_DST
sed -i"" -E "s/,uk,/,gb,/" $SERVERS_DST
sort $SERVERS_DST >$SERVERS_DST.tmp
mv $SERVERS_DST.tmp $SERVERS_DST
