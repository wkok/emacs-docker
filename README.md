# Emacs Docker Container

My emacs + clojure development docker container image

## Contents

- Emacs 28.1
- Open JDK 17
- Clojure 1.11
- Node 16

## Why

Ensures a consistent development environment across workstations

## Prerequisites

- Any Linux host with X11 support (or WSL2 on Windows 11+)
- Docker Engine / Docker Desktop

## Start the container with GUI emacs

`bash <(curl -s https://raw.githubusercontent.com/wkok/emacs-docker/main/start.sh)`

Note: This script mounts your $HOME into the container's $HOME so from within emacs, you'll have access to the same files as your host.

(Download & edit this start.sh if you want to change volume & port mappings)

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
