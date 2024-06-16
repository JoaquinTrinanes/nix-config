{ self, ... }:
{
  system-parts.users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      sshPublicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
      ];
      homeManager = {
        enable = true;
        modules = [ ../home/users/joaquin ];
        hosts = {
          razer-blade-14 = {
            enable = true;
            override =
              _osConfig:
              { config, ... }:
              {
                impurePath = {
                  enable = true;
                  flakePath = "${config.home.homeDirectory}/Documents/nix-config";
                  repoUrl = "https://github.com/JoaquinTrinanes/nix-config.git";
                };
              };
          };
          media-server.enable = true;
        };
      };
    };
  };
  system-parts.homeManager = {
    perUser = user: {
      _module.args = {
        inherit user;
      };
    };
    modules = [ ../home/global ] ++ builtins.attrValues self.homeManagerModules;
    standaloneModules = [ ../home/global/standalone.nix ];
  };
}
