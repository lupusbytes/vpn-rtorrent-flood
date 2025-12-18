FROM alpine:3.23.2

ENV USER=rtorrent
ENV PUID=1000
ENV PGID=1000
ENV INCOMING_PORT=50000

# Optional ENV's
ENV DEFAULT_GATEWAY=
ENV DNS_SERVERS=

# Install rTorrent
RUN apk add rtorrent

# Create volumes/directories with correct ownerships
RUN mkdir "/data" && chown "$PUID":"$PGID" "/data"
VOLUME [ "/data" ]

# Create rTorrent user
RUN addgroup --gid "$PGID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/data" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$PUID" \
    "$USER"

COPY rtorrent.rc /etc/rtorrent/rtorrent.rc
COPY entrypoint.sh /run/entrypoint.sh
ENTRYPOINT /run/entrypoint.sh