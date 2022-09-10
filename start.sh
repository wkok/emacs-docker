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

docker run -it --privileged --rm \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -v /home/wrk:/home/developer \
       -e DISPLAY=$DISPLAY \
       -p 8280:8280 \
       -p 9630:9630 \
       -p 9005:9005 \
       -p 2021:2021 \
       -p 9032:9032 \
       -p 22:22 \
       --user 1000 \
       --name dev \
       wkok/dev:2022-08-23
