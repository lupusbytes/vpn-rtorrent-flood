#!/bin/sh
echo "Deleting locks"
rm -rf /data/session/rtorrent.lock /data/session/rtorrent.pid

if [[ ! -z "$DNS_SERVERS" ]]; then
    echo "Setting DNS server(s) to $DNS_SERVERS"
    echo $DNS_SERVERS | tr ',' '\n' | while read server; do echo "nameserver $server"; done > /etc/resolv.conf
fi

if [[ ! -z "$DEFAULT_GATEWAY" ]]; then
    OLD_DEFAULT_GATEWAY="$(ip route show default | awk '/default/ {print $3}')"
    echo "Changing default gateway from $OLD_DEFAULT_GATEWAY to $DEFAULT_GATEWAY"
    route add default gw $DEFAULT_GATEWAY dev eth0
    route del default gw $OLD_DEFAULT_GATEWAY dev eth0
fi

if [[ ! -f "/data/rtorrent.rc" ]]; then
    cp /etc/rtorrent/rtorrent.rc /data/rtorrent.rc
fi

echo "Setting rTorrent incoming port to $INCOMING_PORT"
grep -q "network.port_range.set" /data/rtorrent.rc
if [[ $? == 0 ]]; then
    sed -i "s/network.port_range.set.*/network.port_range.set = $INCOMING_PORT-$INCOMING_PORT/g" /data/rtorrent.rc
else
    sed -i "$ a ## Set the incoming port" /data/rtorrent.rc
    sed -i "$ a network.port_range.set = $INCOMING_PORT-$INCOMING_PORT" /data/rtorrent.rc
fi

chown "$PUID":"$PGID" /data/rtorrent.rc

echo "Starting rTorrent as user: $USER"
su "$USER" -c "rtorrent -D -o import=/data/rtorrent.rc -o system.daemon.set=true && sleep infinity"
