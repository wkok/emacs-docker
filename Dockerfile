FROM debian:bullseye-slim

#####################################################################################
# Ref: https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/ #
#####################################################################################

ARG EMACS_VERSION=28.1
ARG JAVA_VERSION=17
ARG CLOJURE_VERSION=1.11.1.1113
ARG CLOJURE_LSP_VERSION=2022.05.31-17.35.50
ARG BABASHKA_VERSION=0.8.157
ARG NODE_VERSION=16.x
ARG PLANTUML_VERSION=1.2022.6

#######################################
# Needed for emacs native compilation #
#######################################
ARG CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10

###########################
## Download dependencies ##
###########################
RUN apt-get update && \
    apt install -y build-essential libgtk-3-dev libgnutls28-dev libtiff5-dev libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo autoconf libjansson4 libjansson-dev libgccjit0 libgccjit-10-dev gcc-10 g++-10 wget git ispell unzip openjdk-$JAVA_VERSION-jdk curl rlwrap sudo silversearcher-ag ncat pass telnet graphviz

##############################
# Download and extract emacs #
##############################
RUN wget -O /tmp/emacs.tar.gz http://ftp.gnu.org/gnu/emacs/emacs-$EMACS_VERSION.tar.gz && \
    tar -xf /tmp/emacs.tar.gz -C /tmp

WORKDIR /tmp/emacs-$EMACS_VERSION

#############################
# Compile and install emacs #
#############################
RUN ./autogen.sh && \
    ./configure --with-native-compilation --with-json && \
    make -j8 && \
    make install

##################
# Install NodeJS #
##################
RUN curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | bash -
RUN apt-get install -y nodejs

###################
# Install clojure #
###################
RUN curl -O https://download.clojure.org/install/linux-install-$CLOJURE_VERSION.sh
RUN chmod +x linux-install-$CLOJURE_VERSION.sh
RUN ./linux-install-$CLOJURE_VERSION.sh && \
    rm ./linux-install-$CLOJURE_VERSION.sh

##############################
# Install clojure-lsp native #
##############################
RUN wget -O /tmp/clojure-lsp.zip https://github.com/clojure-lsp/clojure-lsp/releases/download/$CLOJURE_LSP_VERSION/clojure-lsp-native-linux-amd64.zip
RUN unzip /tmp/clojure-lsp.zip -d /usr/local/bin

####################
# Install Babashka #
####################
RUN wget -O /tmp/babashka.tar.gz https://github.com/babashka/babashka/releases/download/v$BABASHKA_VERSION/babashka-$BABASHKA_VERSION-linux-amd64.tar.gz && \
    tar -xf /tmp/babashka.tar.gz -C /usr/local/bin

########################
# Install Firebase CLI #
########################
RUN curl -sL https://firebase.tools | bash

############
# PlantUML #
############
RUN mkdir -p /opt/plantuml && \
    wget -O /opt/plantuml/plantuml.jar https://github.com/plantuml/plantuml/releases/download/v$PLANTUML_VERSION/plantuml-$PLANTUML_VERSION.jar


#################################
# Set up developer user profile #
#################################
RUN useradd -G sudo -u 1000 --create-home -p $(echo "changeme" | openssl passwd -1 -stdin) developer

ENV HOME /home/developer
ENV SHELL /bin/bash

WORKDIR $HOME

###########
# Cleanup #
###########
RUN rm /tmp/emacs.tar.gz && \
    rm -rf /tmp/emacs-$EMACS_VERSION && \
    rm /tmp/clojure-lsp.zip && \
    rm -rf /var/lib/apt/lists/*
