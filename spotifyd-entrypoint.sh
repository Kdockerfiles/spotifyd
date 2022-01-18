#!/usr/bin/env sh

/spotifyd --no-daemon -b sdl $@ | grep --line-buffered -v 'type 47 is invalid' >&2
