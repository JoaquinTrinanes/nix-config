{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  environment.binsh = lib.mkDefault (lib.getExe pkgs.dash);

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

  time.timeZone = lib.mkOptionDefault "UTC";

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
