{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") (inputs // {p = inputs.nixpkgs;});
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
    ["/etc/nix/path"]
    ++
    # TODO: ideally find a way to add it to /etc/nix/path as a file
    lib.mapAttrsToList (name: value: "${name}=channel:${value}") extraNixpkgsAliases;

  nix.channel.enable = lib.mkDefault false;
  # Disabling channels makes nix.nixPath not work
  nix.settings.nix-path = lib.mkIf (!config.nix.channel.enable) config.nix.nixPath;

  systemd = lib.mkMerge [
    # Cleanup channel + $HOME files
    (let
      deleteFile = f: "R ${f} - - - - -";
      channelsFiles = lib.flatten (map (p: ["%h/.nix-${p}" "%h/.local/state/nix/${p}"]) ["channels" "defexpr"]);
      commonFiles = lib.optionals (!config.nix.channel.enable) channelsFiles ++ lib.optionals (config.nix.settings.use-xdg-base-directories or false) ["%h/.nix-profile"];
      rules = map deleteFile commonFiles;
    in {
      tmpfiles.rules =
        rules
        ++ lib.optionals (!config.nix.channel.enable) [
          (deleteFile "/nix/var/nix/profiles/per-user/root/channels")
        ];
      user.tmpfiles.rules = rules;
    })
    (lib.mkIf config.networking.networkmanager.enable {
      network.wait-online.enable = lib.mkDefault false;
      services.NetworkManager-wait-online.enable = lib.mkDefault false;
    })
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
