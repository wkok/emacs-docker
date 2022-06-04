#!/bin/bash

#############################################################
#
# X11 forwarding:
# https://dev.to/acro5piano/we-can-virtualize-even-gui-text-editor-with-docker-container--5bhh
#
# Port mappings:
# - 8280 shadow-cljs http server
# - 9630 shadow-cljs ws server
#
#############################################################

docker run -it --rm \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v /home/wrk:/home/dev \
       -e DISPLAY=$DISPLAY \
       -p 8280:8280 \
       -p 9630:9630 \
       --user 1000 \
       --name dev \
       wkok/dev:2022-06-04
