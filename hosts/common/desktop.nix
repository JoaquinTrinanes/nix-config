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
    printing.enable = true;
    yubikey.enable = true;
  };

  boot.tmp = lib.mkDefault {
    cleanOnBoot = true;
    useTmpfs = false;
  };

  services.xserver.xkb = {
    layout = "us,es";
    options = lib.mkMerge [
      "terminate:ctrl_alt_bksp"
      "lv3:ralt_switch"
      "caps:escape"
    ];
  };
  console.useXkbConfig = true;

  nix.settings.trusted-users = [ "@wheel" ];

  environment.etc."nixos/current-config".source = inputs.self;

  systemd.tmpfiles.settings."${config.networking.hostName}" = {
    "/etc/nixos/flake.nix"."L+" = {
      argument = "${config.users.users."joaquin".home}/Documents/nix-config/flake.nix";
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      age
      bubblewrap
      htop
      jc
      jq
      ldns
      lm_sensors
      lshw
      lsof
      man-pages
      pciutils
      powertop
      srm
      usbutils
      wget
      ;
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
      extraGroups = [
        "users"
        "wheel"
        "networkmanager"

        "dialout" # allow connecting to arduino
      ]
      ++ lib.optionals config.programs.adb.enable [ "adbusers" ]
      ++ lib.optionals config.services.printing.enable [ "lp" ]
      ++ lib.optionals config.virtualisation.docker.enable [
        "docker"
      ]
      ++ lib.optionals config.virtualisation.podman.enable [ "podman" ]
      ++ lib.optionals config.security.tpm2.enable [ "tss" ];
    };
  };

  systemd.tmpfiles.settings."stash" = {
    "/stash/joaquin"."D" = {
      mode = "0700";
      user = config.users.users.joaquin.name;
      inherit (config.users.users.joaquin) group;
    };
  };
  fileSystems."/stash" = {
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=2G"
      "noswap"
      "mode=1777"
      "noatime"
      "nofail"
    ];
    noCheck = true;
  };

  networking = {
    wireless.iwd.enable = true;
    nftables.enable = true;
    # nameservers = [
    #   "9.9.9.9#dns.quad9.net"
    #   "149.112.112.112#dns.quad9.net"
    #   "2620:fe::fe#dns.quad9.net"
    #   "2620:fe::9#dns.quad9.net"
    # ];
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = true;
        macAddress = "random";
        backend = "iwd";
      };
      ethernet.macAddress = "random";
    };
  };

  # services.resolved = {
  #   enable = true;
  #   fallbackDns = [ ];
  #   dnsovertls = "true";
  #   dnssec = "true";
  #   domains = [ "~." ];
  # };

  programs.nix-ld.enable = true;

  i18n.defaultLocale = "en_DK.UTF-8";
}
