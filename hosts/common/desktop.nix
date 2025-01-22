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
    garbageCollect.enable = true;
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
      # "1.1.1.1"
      "1.1.1.1#one.one.one.one"
      "2606:4700:4700::1111"
      # "1.0.0.1"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1001"
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
    # dnssec = "allow-downgrade";
    enable = true;
    # TODO: not sure if this is relevant
    fallbackDns = [
      # "1.1.1.1#one.one.one.one"
      # "2606:4700:4700::1111"
      # "1.0.0.1#one.one.one.one"
      # "2606:4700:4700::1001"
      # "127.0.0.1"
      # "::1"
    ];
    dnsovertls = "opportunistic";
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
    enableOnBoot = false;
  };

  services.switcherooControl.enable = true;

  programs.nix-ld.enable = true;

  i18n.defaultLocale = "en_DK.UTF-8";

  system.stateVersion = "24.11";
}
