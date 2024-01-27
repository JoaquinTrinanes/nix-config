{
  users,
  lib,
  ...
}: let
  sshConfig = {
    openssh.authorizedKeys.keys = users."joaquin".sshPublicKeys;
  };
in {
  networking.networkmanager.enable = true;
  networking.firewall.allowPing = true;

  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = true;
  };

  imports = [
    ./hardware-configuration.nix
    ../common/ssh/server.nix
    ../common/jellyfin
    ../common/samba
    ../common/tailscale
    ../common/home-assistant
  ];

  services.logind.lidSwitch = "ignore";

  services.tailscale.extraUpFlags = lib.mkForce ["--ssh" "--advertise-tags=tag:server"];

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
  };

  users.users."root" = sshConfig;
  users.users."media" =
    sshConfig
    // {
      hashedPassword = "";
      isNormalUser = true;
    };
}
