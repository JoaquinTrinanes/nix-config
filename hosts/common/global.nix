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
  extraRegistryEntries = {unstable = "nixpkgs-unstable";};
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
      extraRegistryEntries)
    # {
    #   # Add nixpkgs-unstable HEAD to the registry
    #   unstable = {
    #     to = {
    #       owner = "NixOS";
    #       ref = "nixpkgs-unstable";
    #       repo = "nixpkgs";
    #       type = "github";
    #     };
    #   };
    # }
    (lib.mapAttrs (_: input: {flake = input;}) flakeInputs)
  ];

  environment.etc."nix/path".source = pkgs.linkFarm "nixPath" (
    flakeInputs
    // (lib.mapAttrs (
        name: value:
          pkgs.writeTextFile {
            inherit name;
            text = "channel:${value}";
          }
      )
      extraRegistryEntries)
  );
  # environment.etc."nix/path".source = pkgs.linkFarm "nixPath" (lib.mapAttrs (_: value: value.flake) registryInputs);

  nix.nixPath = [
    "/etc/nix/path"
    # Adding unstable to the registry won't affect NIX_PATH as it's not a flake, so we set it to follow the channel
    # TODO: this based on extraRegistryEntries or find a way to add it to NIX_PATH as a file
    "unstable=channel:nixpkgs-unstable"
  ];

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
