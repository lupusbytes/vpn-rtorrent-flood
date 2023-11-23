#!/bin/sh
echo "Deleting locks"
rm -rf /config/.local/share/rtorrent/.session/rtorrent.lock /config/.local/share/rtorrent/.session/rtorrent.pid

if [[ ! -z "$DNS_SERVER" ]]
then
    echo "Setting DNS server to $DNS_SERVER"
    echo "nameserver $DNS_SERVER" > /etc/resolv.conf
fi

if [[ ! -z "$DEFAULT_GATEWAY" ]]
then
    OLD_DEFAULT_GATEWAY="$(ip route show default | awk '/default/ {print $3}')"
    echo "Changing default gateway from $OLD_DEFAULT_GATEWAY to $DEFAULT_GATEWAY"
    route add default gw $DEFAULT_GATEWAY dev eth0
    route del default gw $OLD_DEFAULT_GATEWAY dev eth0
fi

echo "Starting rtorrent as user: $USER"
su "$USER" -c "rtorrent"
