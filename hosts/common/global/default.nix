{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  environment.binsh = lib.mkDefault "${pkgs.dash}/bin/dash";
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
    experimental-features = ["nix-command" "flakes" "no-url-literals"];
    trusted-users = ["joaquin"];
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
    substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org" "https://nushell-nightly.cachix.org"];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc="
    ];
    keep-outputs = true;
  };

  time.timeZone = lib.mkDefault "Europe/Madrid";

  environment.systemPackages = with pkgs; [
    htop
    fd
    fzf
    git
    lshw
    lua-language-server
    pciutils
    pinentry
    ripgrep
    sd
    stylua
    unzip
    coreutils
    # uutils-coreutils-noprefix
    wget
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
