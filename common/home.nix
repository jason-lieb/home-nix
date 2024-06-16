{ pkgs, pkgs-unstable, ... }:

{
  home.username = "jason";
  home.homeDirectory = "/home/jason";
  home.stateVersion = "23.11";

  home.sessionVariables.EDITOR = "hx";

  imports = [
    ./modules/firefox.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vscode.nix
  ];

  home.file = let
    env = import ./modules/env.nix;
    alacritty = import ./modules/alacritty.nix;
    helix = import ./modules/helix.nix;
    nix-cache = import ./modules/nix-cache.nix { inherit env; };
    aws = import ./modules/aws.nix;
    stack = import ./modules/stack.nix;
    autostart = import ./modules/autostart.nix { inherit pkgs pkgs-unstable; };
  in builtins.listToAttrs
  ([ alacritty helix nix-cache aws stack ] ++ autostart);
}
