FROM alpine:3.24.1 AS build
ARG VERSION=0.16.14

RUN apk add --no-cache \
    autoconf \
    autoconf-archive \
    automake \
    build-base \
    curl-dev \
    libtool \
    linux-headers \
    ncurses-dev \
    openssl-dev \
    pkgconf \
    xmlrpc-c-dev \
    zlib-dev

# Build libtorrent (static, so it embeds into the rtorrent binary)
RUN wget -O /tmp/libtorrent.tar.gz "https://github.com/rakshasa/libtorrent/archive/refs/tags/v${VERSION}.tar.gz" \
    && tar -xzf /tmp/libtorrent.tar.gz -C /tmp \
    && cd "/tmp/libtorrent-${VERSION}" \
    && autoreconf -i \
    && ./configure \
        --prefix=/usr \
        --disable-debug \
        --enable-static \
        --disable-shared \
    && make -j"$(nproc)" \
    && make install

# Build rtorrent
RUN wget -O /tmp/rtorrent.tar.gz "https://github.com/rakshasa/rtorrent/archive/refs/tags/v${VERSION}.tar.gz" \
    && tar -xzf /tmp/rtorrent.tar.gz -C /tmp \
    && cd "/tmp/rtorrent-${VERSION}" \
    && autoreconf -i \
    && ./configure \
        --prefix=/usr \
        --disable-debug \
        --with-xmlrpc-c \
    && make -j"$(nproc)" \
    && make install

# Final stage/image (minimal rtorrent runtime)
FROM alpine:3.24.1

ENV USER=rtorrent
ENV PUID=1000
ENV PGID=1000
ENV INCOMING_PORT=50000

# Optional ENV's
ENV DEFAULT_GATEWAY=
ENV DNS_SERVERS=

COPY --from=build /usr/bin/rtorrent /usr/bin/rtorrent

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
    libstdc++ \
    ncurses \
    openssl \
    xmlrpc-c \
    zlib

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