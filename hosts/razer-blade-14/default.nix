{
  pkgs,
  hostname,
  ...
}: {
  imports = [
    ../common/global
    ../common/optional/desktop
    ../common/optional/home-manager.nix
    ../common/optional/gaming
    ./hardware-configuration.nix
  ];
  # TODO: Set your hostname
  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    "joaquin" = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "docker"];
    };
  };

  networking.networkmanager.enable = true;

  fonts.packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})];

  virtualisation.docker = {
    enable = true;
    # rootless.enable = true;
  };

  # environment.sessionVariables = rec {
  #   XDG_CACHE_HOME = "$HOME/.cache";
  #   XDG_CONFIG_HOME = "$HOME/.config";
  #   XDG_DATA_HOME = "$HOME/.local/share";
  #   XDG_STATE_HOME = "$HOME/.local/state";

  # Not officially in the specification
  #   XDG_BIN_HOME = "$HOME/.local/bin";
  #   PATH = [ "${XDG_BIN_HOME}" ];
  # };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   # Forbid root login through SSH.
  #   permitRootLogin = "no";
  #   # Use keys only. Remove if you want to SSH using password (not recommended)
  #   passwordAuthentication = false;
  # };
}
