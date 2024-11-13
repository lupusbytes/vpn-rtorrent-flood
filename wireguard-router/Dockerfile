FROM alpine:3.20.3

ENV DNS_SERVERS=1.1.1.1

# Install wireguard-tools and iptables
RUN apk add wireguard-tools iptables

# Prevents wg-quick from attempting to set sysctl parameters that have already been set (preventing it from starting up).
RUN sed -i 's/cmd sysctl -q \(.*\?\)=\(.*\)/[[ "$(sysctl -n \1)" != "\2" ]] \&\& \0/' /usr/bin/wg-quick

VOLUME wireguard.conf /etc/wireguard/wg0.conf
COPY entrypoint.sh /run/entrypoint.sh

CMD /run/entrypoint.sh