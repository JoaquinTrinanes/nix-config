{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  profiles = {
    desktop.enable = true;
    development.enable = true;
    gaming.enable = true;
    nix-index.enable = true;
    printing.enable = true;
    tailscale.enable = true;
    yubikey.enable = true;
  };

  services.tailscale.enable = false;
  services.tailscale.extraUpFlags = [ "--advertise-tags=tag:desktop" ];

  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = false;

  nix.settings.trusted-users = [ "@wheel" ];

  environment.etc."nixos/current-config".source = inputs.self;

  systemd.tmpfiles.settings."${config.networking.hostName}" = {
    "/etc/nixos/flake.nix"."L+" = {
      argument = "${config.users.users."joaquin".home}/Documents/nix-config/flake.nix";
    };
  };

  users.groups = {
    "joaquin" = {
      gid = config.users.users.joaquin.uid;
    };
  };
  users.users = {
    "joaquin" = {
      uid = 1000;
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      group = "joaquin";
      openssh.authorizedKeys.keys = [ ];
      extraGroups =
        [
          "users"
          "wheel"
          "networkmanager"
        ]
        ++ lib.optionals config.programs.adb.enable [ "adbusers" ]
        ++ lib.optionals config.services.printing.enable [ "lp" ]
        ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
        ++ lib.optionals config.security.tpm2.enable [ "tss" ];
    };
  };

  networking = {
    wireless.iwd.enable = true;
    nftables.enable = true;
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = true;
        backend = "iwd";
      };
    };
  };

  services.resolved = {
    enable = true;
    fallbackDns = [ ];
    dnsovertls = "true";
    dnssec = "true";
    domains = [ "~." ];
  };

  programs.nix-ld.enable = true;

  i18n.defaultLocale = "en_DK.UTF-8";
}
