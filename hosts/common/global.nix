{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") (inputs // {p = inputs.nixpkgs;});
  # registryInputs = lib.pipe (inputs // {p = inputs.nixpkgs;}) [
  #   (lib.filterAttrs (_: lib.isType "flake"))
  #   (lib.mapAttrs (_: flake: {inherit flake;}))
  # ];
  extraNixpkgsAliases = {unstable = "nixpkgs-unstable";};
in {
  environment.binsh = lib.mkDefault (lib.getExe pkgs.dash);

  nix.registry = lib.mkMerge [
    (lib.mapAttrs (_: value: {
        to = {
          owner = "NixOS";
          ref = value;
          repo = "nixpkgs";
          type = "github";
        };
      })
      extraNixpkgsAliases)
    (lib.mapAttrs (_: input: {flake = input;}) flakeInputs)
  ];

  environment.etc."nix/path".source = pkgs.linkFarm "nixPath" flakeInputs;

  nix.nixPath =
    [
      "/etc/nix/path"
    ]
    ++
    # TODO: ideally find a way to add it to /etc/nix/path as a file
    lib.mapAttrsToList (name: value: "${name}=channel:${value}") extraNixpkgsAliases;

  nix.channel.enable = lib.mkDefault false;
  # Disabling channels makes nix.nixPath not work
  nix.settings.nix-path = lib.mkIf (!config.nix.channel.enable) config.nix.nixPath;

  # Cleanup channel files
  systemd.tmpfiles.rules = lib.mkIf (!config.nix.channel.enable) [
    "R /nix/var/nix/profiles/per-user/root/channels - - - - -"
    "R /root/.nix-channels - - - - -"
  ];
  systemd.user.tmpfiles.rules = lib.mkIf (!config.nix.channel.enable) [
    "R %h/.nix-defexpr - - - - -"
    "R %h/.local/state/nix/profiles/channels - - - - -"
    "R %h/.nix-channels - - - - -"
  ];

  environment.sessionVariables = lib.mkIf config.nixpkgs.config.allowUnfree {
    NIXPKGS_ALLOW_UNFREE = toString 1;
  };

  networking.usePredictableInterfaceNames = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    age
    age-plugin-yubikey
    coreutils
    fd
    fzf
    git
    htop
    jc
    jq
    ldns
    lshw
    openssl
    pciutils
    pinentry
    ripgrep
    sd
    srm
    unzip
    wget
  ];

  programs.neovim = lib.mkDefault {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
