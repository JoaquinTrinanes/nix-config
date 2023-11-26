_: let
  sshConfig = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII95dwUzUX98GxBzc13L/u/k+0rnZys6xDhNeEdkrsbq joaquin@razer-blade-14"
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
  ];

  users.users."root" = sshConfig;
  users.users."media" =
    sshConfig
    // {
      hashedPassword = "";
      isNormalUser = true;
    };
}
