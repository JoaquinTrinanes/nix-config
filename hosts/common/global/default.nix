{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}: {
  imports = [];
  system.stateVersion = "23.11";
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
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

  environment.systemPackages = with pkgs; [
    alejandra
    nil
    git
    wget
    nil
    rnix-lsp
    nixfmt
    gcc
    libgcc
    wl-clipboard
    libcxx
    stylua
    ripgrep
    sd
    fd
    fzf
    gnumake
    lua-language-server
    pciutils
    lshw
    unzip
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.nix-ld.enable = true;
  programs.npm.enable = true;
}
