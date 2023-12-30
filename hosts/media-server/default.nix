{pkgs, ...}: let
  sshConfig = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
    ];
  };
in {
  networking.networkmanager.enable = true;
  networking.firewall.allowPing = true;

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
