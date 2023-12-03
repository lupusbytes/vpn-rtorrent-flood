#!/bin/sh
WAN_IF="eth1"
WG_IF="wg0"

if [ ! -f "/etc/wireguard/wg0.conf" ]; then
    echo "Wireguard config not mounted to /etc/wireguard/wg0.conf" >&2
    exit 1
fi

echo "Setting DNS server(s) to $DNS_SERVERS"
echo $DNS_SERVERS | tr ',' '\n' | while read server; do echo "nameserver $server"; done > /etc/resolv.conf

echo "Starting Wireguard $interface"
wg-quick up $WG_IF

echo 'Enabling source NAT'
iptables --table nat --append POSTROUTING --out-interface $WG_IF -j MASQUERADE
iptables --append FORWARD --in-interface $WAN_IF -j ACCEPT

if [ ! -z "$PORTFORWARD_PORT" ] && [ ! -z "$PORTFORWARD_IPADDRESS" ]; then
    echo "Setting up destination NAT from port $PORTFORWARD_PORT to $PORTFORWARD_IPADDRESS:$PORTFORWARD_PORT"
    iptables -A PREROUTING -t nat -i $WG_IF -p tcp --dport $PORTFORWARD_PORT -j DNAT --to $PORTFORWARD_IPADDRESS:$PORTFORWARD_PORT
fi

# Handle shutdown behavior
finish () {
    wg-quick down $WG_IF
    exit 0
}
trap finish TERM INT QUIT

sleep infinity &
wait $!