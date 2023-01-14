# Emacs Docker Container

My emacs + clojure development docker container image

## Contents

- EMACS_VERSION=28.2
- JAVA_VERSION=17
- CLOJURE_VERSION=1.11.1.1208
- CLOJURE_LSP_VERSION=2022.11.03-00.14.57
- BABASHKA_VERSION=1.0.169
- CLJ_KONDO_VERSION=2023.01.12
- NODE_VERSION=18.x
- PLANTUML_VERSION=1.2023.0
- YARN_VERSION=1.22.19
- JDT_LSP_VERSION=1.18.0
- JDT_LSP_BUILD=202212011657

## Why

Ensures a consistent development environment across workstations

## Prerequisites

- Any Linux host with X11 support (or WSL2 on Windows 11+)
- Docker Engine / Docker Desktop

## Start the container with GUI emacs

`bash <(curl -s https://raw.githubusercontent.com/wkok/emacs-docker/main/start.sh)`

Note: This script mounts your `$HOME` into the container's `$HOME` so from within emacs, you'll have access to the same files as your host.

(Download & edit this `start.sh` if you want to change volume & port mappings)

## User

The default password for the developer user is changeme

It is recommended to change this password using the `passwd` utility

## Set up your GIT identity

`git config --global user.email "you@example.com"`

`git config --global user.name "Your Name"`

## Optionally set up SSH auth with Github

Within emacs, start a shell

`M-x shell`

generate your private/public key pair

`ssh-keygen -t ed25519 -C "your_email@example.com"`

copy your public key to the clipboard

`cat ~/.ssh/id_ed25519.pub`

and paste this public key in your Github settings

## Optionally initialise my emacs configuration

Within emacs, start a shell

`M-x shell`

clone this repo

`git clone git@github.com:wkok/emacs-docker.git $HOME/src/emacs-docker`

run the init script

`./src/emacs-docker/init.sh`

quit emacs

`C-x c`

start emacs

`bash <(curl -s https://raw.githubusercontent.com/wkok/emacs-docker/main/start.sh)`
