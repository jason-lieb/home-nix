{
  description = "Jason's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # nixos-cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };
    freckle.url = "github:freckle/flakes?dir=main";
  };

  outputs =
    {
      self,
      nixpkgs-stable,
      nixpkgs-unstable,
      nix-vscode-extensions,
      home-manager,
      freckle,
    }:
    let
      system = "x86_64-linux";
      nixpkgsConfig = {
        inherit system;
        config.allowUnfree = true;
      };
      vscode-extensions = nix-vscode-extensions.extensions.x86_64-linux;
      pkgs-unstable = import nixpkgs-unstable nixpkgsConfig;
      homeManagerConfig = {
        home-manager.useGlobalPkgs = true;
        # home-manager.useUserPackages = true;
        # home-manager.extraSpecialArgs = {inherit pkgs-stable;};
        home-manager.backupFileExtension = ".backup";
        home-manager.users.jason =
          { pkgs, ... }:
          {
            imports = [
              (import ./home {
                inherit
                  system
                  pkgs
                  freckle
                  vscode-extensions
                  ;
              })
            ];
          };
      };

      mkNixos =
        hostname:
        let
          pkgs = import nixpkgs-stable nixpkgsConfig;
          specialArgs = {
            inherit pkgs-unstable;
          };
        in
        nixpkgs-stable.lib.nixosSystem {
          inherit system;
          inherit specialArgs;
          modules = [
            (import ./nixos { inherit pkgs hostname; })
            home-manager.nixosModules.home-manager
            homeManagerConfig
            # nixos-cosmic.nixosModules.default
            freckle.nixosModules.docker-for-local-dev
            freckle.nixosModules.renaissance-vpn
          ];
        };

      mkHome =
        let
          pkgs = import nixpkgs-stable nixpkgsConfig;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ (import ./home { inherit pkgs freckle vscode-extensions; }) ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkNixos "desktop";
        laptop = mkNixos "laptop";
        chromebook = mkNixos "chromebook";
      };
      homeConfigurations = {
        "jason@debian" = mkHome;
      };
    };
}
