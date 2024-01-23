{users, ...}: let
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

  services.tailscale.extraUpFlags = lib.mkForce ["--ssh" "--advertise-tags=tag:server"];

  services.openvpn.servers = {
    es23 = {
      config = ''config /secrets/vpn/node-es-05.protonvpn.net.udp.ovpn '';
      autoStart = true;
    };
  };

  users.users."root" = sshConfig;
  users.users."media" =
    sshConfig
    // {
      hashedPassword = "";
      isNormalUser = true;
    };
}
