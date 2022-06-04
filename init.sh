#!/bin/bash

git clone git@github.com:wkok/Emacs-configuration.git $HOME/src/emacs-config

# Setup ssh first: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
cd $HOME/src/emacs-config
git submodule update --init

echo '(setq base "~/src/emacs-config/")' > $HOME/.emacs && \
echo '(load (concat base "ca-init.el"))' >> $HOME/.emacs
