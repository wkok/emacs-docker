FROM ubuntu:jammy

ENV LANG=en_US.UTF-8

#####################################################################################
# Ref: https://batsov.com/articles/2021/12/19/building-emacs-from-source-with-pgtk/ #
#####################################################################################

ARG EMACS_VERSION=29
ARG JAVA_VERSION=17
ARG CLOJURE_VERSION=1.11.1.1208
ARG CLOJURE_LSP_VERSION=2023.02.27-13.12.12
ARG BABASHKA_VERSION=1.3.176
ARG CLJ_KONDO_VERSION=2023.03.17
ARG NODE_VERSION=16.x
ARG PLANTUML_VERSION=1.2023.5
ARG YARN_VERSION=1.22.19
ARG FLUTTER_VERSION=3.7.11
ARG ANDROID_STUDIO_VERSION=2022.2.1.18

ARG USER=wkok

#######################################
# Needed for emacs native compilation #
#######################################
ARG CC=/usr/bin/gcc-10 CXX=/usr/bin/gcc-10

###########################
## Download dependencies ##
###########################
RUN apt-get update && \
    apt install -y build-essential libgtk-3-dev libgnutls28-dev libtiff5-dev libgif-dev libjpeg-dev libpng-dev libxpm-dev libncurses-dev texinfo autoconf libjansson4 libjansson-dev libgccjit0 libgccjit-10-dev gcc-10 g++-10 wget git ispell unzip openjdk-$JAVA_VERSION-jdk curl rlwrap sudo silversearcher-ag ncat pass telnet graphviz openssh-server postgresql-client maven locales locales-all markdown pulseaudio clang cmake ninja-build pkg-config liblzma-dev libstdc++-12-dev

###########
# Locales #
###########
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

#################
# Google Chrome #
#################
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

#####################################################################################################################
# Install tree-sitter                                                                                               #
# See: https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter #
#####################################################################################################################
RUN git clone https://github.com/tree-sitter/tree-sitter.git /tmp/tree-sitter && \
    cd /tmp/tree-sitter && \
    make && \
    make install && \
    cp /usr/local/lib/libtree-sitter* /usr/lib

############################################
# Install tree-sitter language definitions #
#    ./build.sh typescript && \
#    ./build.sh javascript && \
############################################
RUN git clone https://github.com/casouri/tree-sitter-module.git /tmp/tree-sitter-module && \
    cd /tmp/tree-sitter-module && \
    ./batch.sh && \
    cp /tmp/tree-sitter-module/dist/* /usr/lib/

###################################
# Clone emacs and checkout branch #
###################################
RUN git clone git://git.sv.gnu.org/emacs.git /tmp/emacs-$EMACS_VERSION && \
    cd /tmp/emacs-$EMACS_VERSION && \
    git checkout origin/emacs-29

#############################
# Compile and install emacs #
#############################
ARG EMACS_GUI
COPY compile-emacs.sh /compile-emacs.sh
RUN ./compile-emacs.sh

##################
# Install NodeJS #
##################
RUN curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | bash -
RUN apt-get install -y nodejs

################
# Install nvm  #
################
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash -

###################
# Install clojure #
###################
RUN curl -O https://download.clojure.org/install/linux-install-$CLOJURE_VERSION.sh
RUN chmod +x linux-install-$CLOJURE_VERSION.sh
RUN ./linux-install-$CLOJURE_VERSION.sh && \
    rm ./linux-install-$CLOJURE_VERSION.sh

####################
# Install deps-new #
####################
RUN clojure -Ttools install io.github.seancorfield/deps-new '{:git/tag "v0.4.13"}' :as new

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
# Install Leiningen #
#####################
RUN wget -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod a+x /usr/local/bin/lein

#####################
# Install clj-kondo #
#####################
RUN curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo && \
    chmod +x install-clj-kondo && \
    ./install-clj-kondo --version $CLJ_KONDO_VERSION

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

##########################
# Install Android Studio #
##########################
RUN mkdir -p /opt/android-studio && \
     wget -O /tmp/android-studio.tar.gz https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$ANDROID_STUDIO_VERSION/android-studio-$ANDROID_STUDIO_VERSION-linux.tar.gz && \
     tar xf /tmp/android-studio.tar.gz -C /opt/

###################
# Install Flutter #
###################
RUN mkdir -p /opt/flutter && \
    wget -O /tmp/flutter.tar.gz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz && \
    tar xf /tmp/flutter.tar.gz -C /opt/ && \
    /opt/flutter/bin/flutter precache

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

## opt permissions
RUN chown -R $USER /opt

###########
# Cleanup #
###########
RUN rm -rf /tmp/emacs-$EMACS_VERSION && \
    rm /tmp/clojure-lsp.zip && \
    rm /tmp/flutter.tar.gz && \
    rm /tmp/android-studio.tar.gz && \
    rm /compile-emacs.sh && \
    rm google-chrome-stable_current_amd64.deb && \
    rm /tmp/babashka.tar.gz && \
    rm -rf /tmp/tree-sitter && \
    rm -rf /tmp/tree-sitter-module && \
    rm -rf /var/lib/apt/lists/*

ENV HOME /home/$USER
ENV SHELL /bin/bash

WORKDIR $HOME

ENTRYPOINT sudo service ssh start && /bin/bash
