#!/usr/bin/env bash

set -e

cd $HOME
mkdir -p ~/.ssh

printf "\nSetting up ssh key..."
printf "\nWhat is your email address? "
read email_address
yes '' | ssh-keygen -t ed25519 -C $email_address &> /dev/null
eval "$(ssh-agent -s)" &> /dev/null
ssh-add $HOME/.ssh/id_ed25519

printf "\nCreating github cli shell and adding SSH key to GitHub...\n"
nix-shell -p gh --run "gh auth login"
printf "\n"
nix-shell -p git --run "git clone git@github.com:jason-lieb/home-nix.git"

printf "\nWhat is the hostname of this computer? "
read hostname
sudo hostname $hostname
mkdir -p $HOME/home-nix/modules/$hostname
sudo cp /etc/nixos/hardware-configuration.nix $HOME/home-nix/modules/$hostname/hardware-configuration.nix

echo "Setting up nix configuration..."
sudo nixos-rebuild switch --flake $HOME/home-nix#$hostname
