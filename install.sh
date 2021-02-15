#!/usr/bin/env bash

echo "Building Nix expression for Emacs.."

args=(
    --cores 0
    -j8
    --no-build-output
    --no-out-link
)
drv=$(nix-build ${args[*]} ./emacs.nix)

if test -n "$drv"
then echo "Got:  $drv"
     echo "Installing the Emacs derivation into user profile.."
     nix-env --install ${drv}
else exit 1
fi
