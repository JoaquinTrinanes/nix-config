{ inputs, ... }:
{
  parts = {
    users = {
      "joaquin" = {
        sshPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
        ];
        home-manager = {
          enable = true;
          modules = [ ../home ];
        };
      };
    };
    home-manager = {
      modules = [
        ../home/global
        ../profiles/home-manager
      ]
      ++ builtins.attrValues inputs.self.modules.homeManager;
      standaloneModules = [ ../home/global/standalone.nix ];
    };
  };
}
