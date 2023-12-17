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
    ./hardware-configuration.nix
  ];

  # use older nix while HM issue #4692 isn't fixed
  nix.package = pkgs.nixVersions.nix_2_18;
  # nix.package = pkgs.nixVersions.unstable;

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
      # Be sure to change it (using passwd) after rebooting!
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

  networking.networkmanager = {
    enable = true;
    wifi = {
      scanRandMacAddress = true;
      backend = "iwd";
    };
  };
  services.resolved = {enable = true;};

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
    # rootless.enable = true;
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
