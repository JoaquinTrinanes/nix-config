{ lib, inputs, ... }:
{
  parts = {
    users = {
      "joaquin" = {
        sshPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
        ];
        home-manager = {
          enable = true;
          modules = [ ../home/users/joaquin ];
          hosts = {
            razer-blade-14.enable = true;
            media-server.enable = true;
          };
        };
      };
    };
    home-manager = {
      perUser = user: { home.username = lib.mkDefault user.name; };
      modules = [ ../home/global ] ++ builtins.attrValues inputs.self.homeManagerModules;
      standaloneModules = [ ../home/global/standalone.nix ];
    };
  };
}
