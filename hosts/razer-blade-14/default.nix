{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common/desktop
    ../common/development
    ../common/gaming
    ../common/nix-index
    ../common/garbage-collect
    ../common/tailscale
    ../common/yubikey
    ../common/printing
    ./hardware-configuration.nix
  ];

  programs.firefox.package = pkgs.firefox-devedition;

  services.tailscale.extraUpFlags = [ "--advertise-tags=tag:desktop" ];

  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;

  nix.settings.trusted-users = [ "@wheel" ];

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos/flake.nix - - - - ${
      config.users.users."joaquin".home
    }/Documents/nix-config/flake.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users = {
    "joaquin" = {
      uid = 1000;
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = lib.mkForce [ ];
      extraGroups =
        [
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
    nftables = {
      enable = true;
    };
    nameservers = [
      "1.1.1.1"
      "2606:4700:4700::1111"
      "1.0.0.1"
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

  # TODO: probably not the issue
  services.avahi.enable = false;
  services.resolved = {
    # dnssec = "allow-downgrade";
    enable = true;
    # TODO: not sure if this is relevant
    fallbackDns = [
      # "127.0.0.1"
      # "::1"
    ];
    dnsovertls = "opportunistic";
  };
  # override firefox's default DNS settings to force the local resolver
  programs.firefox.preferences."network.trr.mode" = lib.mkForce 5;

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
