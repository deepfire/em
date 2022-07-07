#!/usr/bin/env bash

## Pass extra args e.g.:
##
##  --argstr font "Terminus"
##  --argstr font "TerminessTTF Nerd Font Mono"

./install.sh --use-host-nixpkgs "$@"
