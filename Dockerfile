FROM debian:bullseye-slim

ENV LANG=en_US.UTF-8

#####################################################################################
# Ref: https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/ #
#####################################################################################

ARG EMACS_VERSION=28.2
ARG JAVA_VERSION=17
ARG CLOJURE_VERSION=1.11.1.1208
ARG CLOJURE_LSP_VERSION=2022.12.09-15.51.10
ARG BABASHKA_VERSION=1.0.169
ARG CLJ_KONDO_VERSION=2023.01.12
ARG NODE_VERSION=18.x
ARG PLANTUML_VERSION=1.2023.0
ARG YARN_VERSION=1.22.19
ARG JDT_LSP_VERSION=1.18.0
ARG JDT_LSP_BUILD=202212011657

ARG USER=developer

#######################################
# Needed for emacs native compilation #
#######################################
ARG CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10

###########################
## Download dependencies ##
###########################
RUN apt-get update && \
    apt install -y build-essential libgtk-3-dev libgnutls28-dev libtiff5-dev libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo autoconf libjansson4 libjansson-dev libgccjit0 libgccjit-10-dev gcc-10 g++-10 wget git ispell unzip openjdk-$JAVA_VERSION-jdk curl rlwrap sudo silversearcher-ag ncat pass telnet graphviz openssh-server chromium postgresql-client maven

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

#####################
# Install clj-kondo #
#####################
RUN curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo && \
    chmod +x install-clj-kondo && \
    ./install-clj-kondo --version $CLJ_KONDO_VERSION

#############################################
# Install Java Development Tools lsp server #
#############################################
RUN wget -O /tmp/jdt-ls.tar.gz https://download.eclipse.org/jdtls/milestones/$JDT_LSP_VERSION/jdt-language-server-$JDT_LSP_VERSION-$JDT_LSP_BUILD.tar.gz && \
    mkdir -p /opt/jdt-ls && \
    tar -xf /tmp/jdt-ls.tar.gz -C /opt/jdt-ls && \
    ln -s /opt/jdt-ls/bin/jdtls /usr/local/bin/jdtls

###########################
# Install bash lsp server #
###########################
RUN npm i -g bash-language-server

############################################
# Install HTML/CSS/JSON/ESLint lsp servers #
############################################
RUN npm i -g vscode-langservers-extracted

#################################
# Install typescript lsp server #
#################################
RUN npm i -g typescript-language-server typescript

#################################
# Install Dockerfile lsp server #
#################################
RUN npm i -g dockerfile-language-server-nodejs

########################
# Install Firebase CLI #
########################
RUN curl -sL https://firebase.tools | bash

############
# PlantUML #
############
RUN mkdir -p /opt/plantuml && \
    wget -O /opt/plantuml/plantuml.jar https://github.com/plantuml/plantuml/releases/download/v$PLANTUML_VERSION/plantuml-$PLANTUML_VERSION.jar

########
# Yarn #
########
RUN npm install --global yarn@$YARN_VERSION

#######################
# Set up user profile #
#######################
RUN useradd -G sudo -u 1000 --create-home -p $(echo "changeme" | openssl passwd -1 -stdin) $USER

###########################
# Enable no password sudo #
###########################
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER

################################
# Allow X11-Forwarding via SSH #
################################
RUN echo "Match User $USER" >> /etc/ssh/sshd_config && \
    echo "	AllowAgentForwarding yes" >> /etc/ssh/sshd_config && \
    echo "	AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "	X11DisplayOffset 10" >> /etc/ssh/sshd_config && \
    echo "	X11UseLocalhost no" >> /etc/ssh/sshd_config && \
    echo "	X11Forwarding yes" >> /etc/ssh/sshd_config

###########
# Cleanup #
###########
RUN rm /tmp/emacs.tar.gz && \
    rm -rf /tmp/emacs-$EMACS_VERSION && \
    rm /tmp/jdt-ls.tar.gz && \
    rm /tmp/clojure-lsp.zip && \
    rm -rf /var/lib/apt/lists/*

ENV HOME /home/$USER
ENV SHELL /bin/bash

WORKDIR $HOME

ENTRYPOINT sudo service ssh start && /bin/bash
