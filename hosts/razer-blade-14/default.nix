{
  hostname,
  lib,
  config,
  ...
}: {
  imports = [
    ../common/optional/desktop
    ../common/optional/home-manager.nix
    ../common/optional/development
    ../common/optional/nh
    ../common/optional/gaming
    ./hardware-configuration.nix
  ];
  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users = {
    "joaquin" = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
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
    logDriver = "none";
    # rootless.enable = true;
  };

  programs.nix-ld.enable = true;

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
