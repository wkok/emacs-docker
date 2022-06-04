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

bash <(curl -s https://raw.githubusercontent.com/wkok/emacs-docker/main/start.sh)

## Optionally set up SSH auth with Github

Within emacs, start a shell

`M-x shell`

Generate your private/public key pair

`ssh-keygen -t ed25519 -C "your_email@example.com"`

Copy your public key to your clipboard

`cat ~/.ssh/id_ed25519.pub`

and paste this public key in your Github settings

## Optionally initialise my emacs configuration

Within emacs, start a shell

`M-x shell`

Clone this repo

`git clone git@github.com:wkok/emacs-docker.git $HOME/src/emacs-docker`

Run the init script

`./src/emacs-docker/init.sh`

Quit emacs

`C-x c`

Start emacs

`bash <(curl -s https://raw.githubusercontent.com/wkok/emacs-docker/main/start.sh)`
