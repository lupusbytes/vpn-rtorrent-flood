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