#!/usr/bin/env bash
# Borrowed from 0atman: https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

set -e

# cd to your config dir
pushd ~/home-nix

# Early return if no changes were detected
if git diff --quiet '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Shows your changes
git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
git commit -am "$current"

# Back to where you were
popd

notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
