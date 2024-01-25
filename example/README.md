### Steps to succesfully run with `docker compose`
1. Replace [wgtorrent.conf](wgtorrent.conf) with your real WireGuard config.
1. Create `data` and `flood` directories as your default user (NOT ROOT) before starting the containers (`mkdir data flood`).
1. Execute `docker compose up`.
1. Open http://localhost:3000 in a browser, or if you are connecting from a different computer, use http://server_ip_address:3000.
1. Choose a username and password.
1. Select `rTorrent` as Client.
1. Select `Socket` as Connection Type.
1. Set `/data/rtorrent.sock` as Path.
1. Create Account.
1. Enjoy.

### If you failed to create the directories as your default user before starting the containers:
1. Simply change ownership of the directories (`chown -R 1000:1000 data flood` as root or with `sudo`).
1. Continue from step 3.
