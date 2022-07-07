#!/usr/bin/env bash

## Pass extra args e.g.:
##
##  --argstr font "Terminus"
##  --argstr font "TerminessTTF Nerd Font Mono"

derivation_args=(
)
build_args=(
    --cores 0
    -j8
    --no-build-output
    --no-out-link
)

dry_run=
while test $# -ge 1
do case "$1" in
       --use-host-nixpkgs )
           echo "Using host Nixpkgs (CLI).."
           derivation_args+=(--arg useHostNixpkgs true);;
       --dry-run | --build-only )
           echo "Dry run mode (build only)."
           dry_run=t;;
       * ) break;; esac; shift; done


echo "Building Nix expression for Emacs.."

drv=$(nix-build ${build_args[*]} ./default.nix "${derivation_args[@]}")

if test -n "$drv"
then echo "Got:  $drv"
else exit 1
fi

if test -z "$dry_run"
then echo "Installing the Emacs derivation into user profile.."
     nix-env --install ${drv}
fi
