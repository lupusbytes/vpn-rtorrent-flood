FROM alpine:3.18.4

ENV USER=rtorrent
ENV PUID=1000
ENV PGID=1000
ENV MOUNT=/config

# Optional ENV's
ENV DEFAULT_GATEWAY=
ENV DNS_SERVERS=

# Add mounting endpoint for data
RUN apk add rtorrent

RUN mkdir "$MOUNT"
RUN chown "$PUID":"$PGID" "$MOUNT"
RUN addgroup --gid "$PGID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$MOUNT" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$PUID" \
    "$USER"

COPY entrypoint.sh /run/entrypoint.sh
ENTRYPOINT /run/entrypoint.sh