FROM rust:1.58.0-bullseye AS b

COPY sdl.patch /home/

RUN apt update && \
    apt install -y --no-install-recommends libsdl2-dev

ARG SPOTIFYD_V=0.3.3
RUN curl -Lo - https://github.com/Spotifyd/spotifyd/archive/refs/tags/${SPOTIFYD_V}.tar.gz | tar xz -C /home/ && \
    cd /home/spotifyd-${SPOTIFYD_V} && \
    patch -Np1 < ../sdl.patch && \
    cargo build --release --no-default-features --features=sdl_backend && \
    cp target/release/spotifyd /


FROM debian:bullseye

COPY --from=b /spotifyd /

RUN apt update && \
    apt install -y --no-install-recommends libsdl2-2.0-0 libsndio7.0 && \
    apt clean && \
    rm /var/lib/apt/lists/*.lz4

ENV SDL_AUDIODRIVER="sndio"

COPY spotifyd-entrypoint.sh /

ENTRYPOINT ["/spotifyd-entrypoint.sh"]
