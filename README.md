# vpn-rtorrent-flood
![Diagram of service communication](docs/service-diagram-dark-theme.png#gh-dark-mode-only)
![Diagram of service communication](docs/service-diagram-light-theme.png#gh-light-mode-only)

This project aims to provide a minimalistic way to run [WireGuard](https://www.wireguard.com/), [rTorrent](https://github.com/rakshasa/rtorrent), and [Flood](https://github.com/jesec/flood) in cohesive Docker containers, with a seperation of concerns.

## About the services
### Flood
[Flood](https://github.com/jesec/flood) is a modern web interface for rTorrent. The backend is written in Node.js and the frontend in React. It comunicates with rTorrent using XMLRPC over a UNIX socket.

### rTorrent
[rTorrent](https://github.com/rakshasa/rtorrent) is a lightweight and efficient BitTorrent client for Unix-like systems, known for its low resource usage and scalability. It operates in a command-line interface, is powered by the LibTorrent library, and is favored for its speed and ability to handle numerous torrents with minimal system impact.

### WireGuard router
[WireGuard](https://www.wireguard.com/) is a modern, efficient, and secure open-source VPN protocol known for its simplicity and high performance. It offers strong encryption, kernel integration for speed, and cross-platform support.

## Docker Compose example
```
version: '3'
services:
  wireguard:
    container_name: wireguard-router
    image: ghcr.io/lupusbytes/wireguard-router:latest
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PORTFORWARD_PORT=45000
      - PORTFORWARD_IPADDRESS=172.20.0.3
    volumes:
      - ./wgtorrent.conf:/etc/wireguard/wg0.conf
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: always
    networks:
      torrentnet:
        ipv4_address: 172.20.0.2

  rtorrent:
    container_name: rtorrent
    image: ghcr.io/lupusbytes/rtorrent:latest
    depends_on:
      - wireguard
    cap_add:
      - NET_ADMIN
    logging:
      driver: none
    volumes:
      - ./data:/data
    environment:
      - DEFAULT_GATEWAY=172.20.0.2
      - DNS_SERVERS=1.1.1.1
      - INCOMING_PORT=45000
    restart: always
    stdin_open: true
    tty: true
    networks:
      torrentnet:
        ipv4_address: 172.20.0.3

  flood:
    image: jesec/flood:latest
    container_name: flood
    user: "1000:1000"
    depends_on:
      - rtorrent
    command:
      - --allowed-path /data
    volumes:
      - ./flood:/config
      - ./data:/data
    environment:
      - HOME=/config
    ports:
      - "127.0.0.1:3000:3000"
    restart: always
    networks:
      torrentnet:
        ipv4_address: 172.20.0.4

networks:
  torrentnet:
    ipam:
      config:
      - subnet: 172.20.0.0/29
```
## Docker images
## WireGuard router
### Image
* `ghcr.io/lupusbytes/wireguard-router`
### Environment variables
* `DNS_SERVERS`: Comma seperated list of DNS servers to use. (default `1.1.1.1`)
* `PORTFORWARD_PORT`: Port forward a single TCP port through the WireGuard tunnel.
* `PORTFORWARD_IPADDRESS`: Destination IP address of `PORTFORWARD_PORT`.

### Volumes
* `/etc/wireguard/wg0.conf`: Required wireguard config for the router to use.

### Permissions
When running a container based on this image, the follow system capabilities are nescessary:
- `NET_ADMIN`
- `SYS_MODULE`
- `--sysctl net.ipv4.conf.all.src_valid_mark=1`

### Note
`PORTFORWARD_PORT` and `PORTFORWARD_IPADDRESS` variables can be used together to expose the rTorrent `INCOMING_PORT` to the internet.  
This allows rTorrent to become "connectable".  
Being connectable means that you can share data with everyone (be it seeding, or leeching).  
Two unconnectable peers will not be able to communicate with one another.  
Being connectable is not strictly necessary, but it is highly recommended. You can still download and (somewhat) seed while being unconnectable.

## rTorrent
### Image
* `ghcr.io/lupusbytes/rtorrent`
### Environment variables
* `USER`: The username inside the container (default `rtorrent`)
* `PUID`: rTorrent user id (default `1000`)
* `PGID`: rTorrent group id (default `1000`)
* `INCOMING_PORT`: Port number for incoming connections (`network.port_range.set`, default `50000`)
* `DEFAULT_GATEWAY`: Allows for overriding the default gateway. Intended to be used for redirecting traffic to a VPN gateway.
* `DNS_SERVERS`: Comma seperated list of DNS servers to use.

### Volumes
* `/data`: location for `downloads`, `log`, `session`, `watch`, `rtorrent.rc` and `rtorrent.sock`

### Permissions
When running a container based on this image, the follow system capabilities are nescessary:
* `NET_ADMIN`

### Note
When overriding the `DEFAULT_GATEWAY`, the Docker host's DNS servers may not be reachable. Use `DNS_SERVERS` to select a DNS server that is reachable through the tunnel.

## Flood
### Image
* `jesec/flood`
#### Please refer to the docker compose example or [jesec/flood](https://github.com/jesec/flood)