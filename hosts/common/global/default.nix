{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}: {
  system.stateVersion = "23.11";
  nixpkgs = {
    overlays = with outputs.overlays; [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      additions
      modifications
      unstable-packages
      neovim-nightly
    ];
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
    alejandra
    fd
    fzf
    gcc
    git
    gnumake
    libcxx
    libgcc
    lshw
    lua-language-server
    nil
    nil
    nixfmt
    pciutils
    pinentry
    pinentry-gnome
    pinentry-gtk2
    ripgrep
    rnix-lsp
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
