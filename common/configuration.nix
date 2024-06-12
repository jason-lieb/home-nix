{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./modules/gnome.nix
    # inputs.freckle.nixosModules.docker-for-local-dev
    # inputs.freckle.nixosModules.renaissance-vpn
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      netrc-file = /home/jason/.config/nix/netrc
    '';
    settings = {
      trusted-users = [ "@wheel" ];
      max-jobs = 8;
      build-cores = 0;
      substituters = [
        "https://freckle.cachix.org"
        "https://freckle-flakes.cachix.org"
        "https://freckle-private.cachix.org"
      ];
      trusted-public-keys = [
        "freckle.cachix.org-1:WnI1pZdwLf2vnP9Fx7OGbVSREqqi4HM2OhNjYmZ7odo="
        "freckle-flakes.cachix.org-1:d+zszsfs+gamqZPjsGQPtDvpDNhE6pLSmtZDQHYTUDo="
        "freckle-private.cachix.org-1:zbTfpeeq5YBCPOjheu0gLyVPVeM6K2dc1e8ei8fE0AI="
      ];
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver = {
    enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "jason";
    };

    # Configure keymap
    layout = "us";
    xkbVariant = "";
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = "/run/current-system/sw/bin/fish";

  users.users.jason = {
    isNormalUser = true;
    description = "Jason";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;

  environment.systemPackages = (with pkgs; [
    home-manager
    alacritty
    bat
    cachix
    chromium
    firefox
    # docker
    fish
    gh
    git
    github-copilot-cli
    htop
    gnumake
    neofetch
    neovim
    nixfmt
    python3
    ripgrep
    sof-firmware
    wget
    zoxide
  ])

    ++

    (with pkgs-unstable; [ brave obsidian vscode ]);

  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # services.openssh.enable = true;

  system.stateVersion = "23.11";
}