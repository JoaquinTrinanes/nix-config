{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  environment.binsh = "${pkgs.dash}/bin/dash";

  programs.command-not-found.enable = false;
  programs.nix-index = {
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };
  programs.nix-index-database.comma.enable = true;

  system.stateVersion = "23.11";

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry =
    (lib.mapAttrs (_: flake: {inherit flake;}))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
    substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org/"];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  time.timeZone = "Europe/Madrid";

  environment.systemPackages = with pkgs; [
    htop
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
}
