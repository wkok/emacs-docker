#!/bin/bash

cd /tmp/emacs-${EMACS_VERSION}


if [ "${EMACS_GUI}" = "pgtk" ]; then
    ./autogen.sh && \
    ./configure --with-native-compilation --with-json --with-pgtk && \
    make -j8 && \
    make install
elif [ "${EMACS_GUI}" = "x11" ]; then
    ./autogen.sh && \
    ./configure --with-native-compilation --with-json && \
    make -j8 && \
    make install
fi
