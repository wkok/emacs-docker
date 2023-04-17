#!/bin/bash

#############################################################
#
# X11 forwarding:
# https://dev.to/acro5piano/we-can-virtualize-even-gui-text-editor-with-docker-container--5bhh
#
# Port mappings:
# - 8280 shadow-cljs http server
# - 9630 shadow-cljs ws server
# - 9005 firebase cli auth
# - 2021 juxt site
# - 9032 portal
# - 22 ssh
#
#############################################################

docker run -it --privileged --rm --network host \
       -e XDG_RUNTIME_DIR=/tmp \
       -e XDG_SESSION_TYPE=wayland \
       -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
       -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY  \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -e DISPLAY=$DISPLAY \
       -v /home/wkok:/home/wkok \
       --user 1000 \
       --name dev \
       wkok/dev:2023-04-17-pgtk
