{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  environment.binsh = lib.mkDefault (lib.getExe pkgs.dash);

  imports = [
    # add nixpkgs-unstable HEAD to the registry
    {
      nix.registry.unstable = {
        to = {
          owner = "NixOS";
          ref = "nixpkgs-unstable";
          repo = "nixpkgs";
          type = "github";
        };
      };
    }
  ];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry =
    (lib.mapAttrs (_: flake: {inherit flake;}))
    ((lib.filterAttrs (_: lib.isType "flake"))
      (inputs
        // {
          # alias p to nixpkgs
          p = inputs.nixpkgs;
        }));

  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    (lib.filterAttrs (_: x: lib.isType "flake" x.flake) config.nix.registry);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];

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
    coreutils
    fd
    fzf
    git
    htop
    jc
    ldns
    lshw
    openssl
    pciutils
    pinentry
    ripgrep
    sd
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
