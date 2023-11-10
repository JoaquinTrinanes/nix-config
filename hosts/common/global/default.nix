{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  environment.binsh = "${pkgs.dash}/bin/dash";

  programs.command-not-found.enable = false;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableFishIntegration = false;
  programs.nix-index-database.comma.enable = true;

  # console.keyMap = lib.mkDefault "us";

  system.stateVersion = "23.11";
  nixpkgs = {
    overlays = [outputs.overlays.default];
    config.allowUnfree = lib.mkDefault true;
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath =
      lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org/"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  time.timeZone = "Europe/Madrid";

  environment.systemPackages = with pkgs; [
    fd
    fzf
    gcc
    git
    gnumake
    libcxx
    libgcc
    lshw
    lua-language-server
    pciutils
    pinentry
    pinentry-gnome
    pinentry-gtk2
    ripgrep
    sd
    stylua
    unzip
    coreutils
    # uutils-coreutils-noprefix
    wget
    wl-clipboard
  ];

  # services.pcscd.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.nix-ld.enable = true;
  programs.npm.enable = true;
}
