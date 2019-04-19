#!/bin/bash
URL="https://nordvpn.com/ovpn/"
TPL="template"
TMP="tmp"
SERVERS_SRC="$TPL/servers.html"
SERVERS_DST="$TPL/servers.csv"

mkdir -p $TPL
if ! curl -L $URL >$SERVERS_SRC.tmp; then
    exit
fi
mv $SERVERS_SRC.tmp $SERVERS_SRC

# id,country,secondary,num,hostname
grep -E '<span class="mr-2">.*nordvpn.com</span>' $SERVERS_SRC | sed -E 's/.*<span class="mr-2">([A-Za-z]+)(-)?([A-Za-z]+)?([0-9]+)\.nordvpn\.com<.*$/\1\2\3\4,\1,\3,\4,\1\2\3\4.nordvpn.com/' >$SERVERS_DST

# fix wrong UK country code
sed -i"" -E "s/,uk,/,gb,/" $SERVERS_DST
sort $SERVERS_DST >$SERVERS_DST.tmp
mv $SERVERS_DST.tmp $SERVERS_DST
