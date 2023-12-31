{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/optional/desktop
    ../common/optional/development
    ../common/optional/gaming
    ../common/optional/nix-index
    ../common/optional/garbage-collect
    ../common/optional/tailscale
    ./hardware-configuration.nix
  ];

  services.tailscale.extraUpFlags = ["--advertise-tags=tag:desktop"];

  boot.tmp.cleanOnBoot = true;

  nix.settings.trusted-users = ["@wheel"];

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos/flake.nix - - - - ${config.users.users."joaquin".home}/Documents/nix-config/flake.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users = {
    "joaquin" = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups =
        ["wheel" "networkmanager"]
        ++ lib.optionals config.programs.adb.enable ["adbusers"]
        ++ lib.optionals config.services.printing.enable ["lp"]
        ++ lib.optionals config.virtualisation.docker.enable ["docker"];
    };
  };

  networking = {
    nameservers = ["1.1.1.1" "1.0.0.1"];
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
    extraConfig = ''
      # DNSOverTLS=opportunistic
      DNSOverTLS=yes
    '';
  };
  # override firefox's default DNS settings to force the local resolver
  programs.firefox.policies.Preferences."network.trr.mode" = lib.mkForce 5;

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
  };

  services.switcherooControl.enable = true;

  programs.nix-ld.enable = true;

  i18n.defaultLocale = "en_DK.UTF-8";

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     # Forbid root login through SSH.
  #     PermitRootLogin = "no";
  #     # Use keys only. Remove if you want to SSH using password (not recommended)
  #     PasswordAuthentication = false;
  #   };
  # };
}
