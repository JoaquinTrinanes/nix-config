_: let
  sshConfig = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII95dwUzUX98GxBzc13L/u/k+0rnZys6xDhNeEdkrsbq joaquin@razer-blade-14"
    ];
  };
in {
  imports = [
    ./hardware-configuration.nix
    ../common/optional/ssh/server.nix
  ];

  users.users."root" = sshConfig;
  users.users."alfred" =
    sshConfig
    // {
      isNormalUser = true;
    };
}
