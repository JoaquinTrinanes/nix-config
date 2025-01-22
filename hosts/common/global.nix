{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  flakeAliases = {
    nixpkgs-unstable.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };
    nixpkgs-head.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "HEAD";
    };
    p.flake = inputs.nixpkgs;
    templates.to = {
      type = "github";
      owner = "NixOS";
      repo = "templates";
      ref = "HEAD";
    };
  };
in
{
  environment.binsh = lib.mkDefault (lib.getExe pkgs.dash);

  boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packageAliases.linux_latest;

  documentation.nixos.enable = false;

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  nix.registry = lib.mkMerge [
    flakeAliases
    (lib.mapAttrs (_: input: { flake = input; }) flakeInputs)
  ];

  nix.nixPath = lib.mkMerge [
    (lib.mapAttrsToList (name: _: "${name}=flake:${name}") (flakeInputs // flakeAliases))
  ];

  nix.channel.enable = lib.mkDefault false;
  # Disabling channels makes nix.nixPath not work
  nix.settings.nix-path = lib.mkIf (!config.nix.channel.enable) config.nix.nixPath;

  environment.sessionVariables.NIX_PATH = lib.mkIf (!config.nix.channel.enable) (lib.mkForce "");

  systemd = lib.mkMerge [
    # Cleanup channel + $HOME files
    (
      let
        deleteFile = f: "R ${f} - - - - -";
        channelsFiles = lib.flatten (
          map
            (p: [
              "%h/.nix-${p}"
              "%h/.local/state/nix/${p}"
            ])
            [
              "channels"
              "defexpr"
            ]
        );
        commonFiles =
          lib.optionals (!config.nix.channel.enable) channelsFiles
          ++ lib.optionals (config.nix.settings.use-xdg-base-directories or false) [ "%h/.nix-profile" ];
        rules = map deleteFile commonFiles;
      in
      {
        tmpfiles.rules = lib.mkMerge [
          rules
          (lib.mkIf (!config.nix.channel.enable) [
            (deleteFile "/nix/var/nix/profiles/per-user/root/channels")
          ])
        ];
        user.tmpfiles.rules = rules;
      }
    )
    (lib.mkIf config.networking.networkmanager.enable {
      network.wait-online.enable = lib.mkDefault false;
      services.NetworkManager-wait-online.enable = lib.mkDefault config.systemd.network.wait-online.enable;
    })
  ];

  networking.timeServers = [
    "0.pool.ntp.org"
    "1.pool.ntp.org"
    "2.pool.ntp.org"
    "3.pool.ntp.org"
  ];

  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "nts1.roa.es"
      "time.cloudflare.com"
      "ntppool1.time.nl"
      "ntppool2.time.nl"
    ];
  };

  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = lib.mkIf config.nixpkgs.config.allowUnfree "1";

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
    lsof
    openssl
    pciutils
    powertop
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
