#!/usr/bin/env bash

derivation_args=(
)
build_args=(
    --cores 0
    -j8
    --no-build-output
    --no-out-link
)

while test $# -ge 1
do case "$1" in
       --use-host-nixpkgs )
           echo "Using host Nixpkgs (CLI).."
           derivation_args+=(--arg use-host-nixpkgs true);;
       * ) break;; esac; shift; done


echo "Building Nix expression for Emacs.."

drv=$(nix-build ${build_args[*]} ./emacs.nix "${derivation_args[@]}")

if test -n "$drv"
then echo "Got:  $drv"
     echo "Installing the Emacs derivation into user profile.."
     nix-env --install ${drv}
else exit 1
fi
