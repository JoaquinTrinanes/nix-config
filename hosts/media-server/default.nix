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
    ../common/optional/ssh/server.nix
    ../common/optional/jellyfin
    ../common/optional/samba
    ../common/optional/tailscale
  ];

  services.tailscale.extraUpFlags = [];

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
