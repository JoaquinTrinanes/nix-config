{ self, lib, ... }:
{

  config.system-parts = {
    users = {
      "joaquin" = {
        email = "hi@joaquint.io";
        firstName = "Joaquín";
        lastName = "Triñanes";
        sshPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
        ];
        home-manager = {
          enable = true;
          modules = [ ../home/users/joaquin ];
          hosts = {
            razer-blade-14 = {
              enable = true;
            };
            media-server = {
              enable = true;
            };
          };
        };
      };
    };
    home-manager = {
      perUser = user: {
        _module.args = {
          inherit user;
        };
      };
      modules = [ ../home/global ] ++ builtins.attrValues self.homeManagerModules;
      standaloneModules = [ ../home/global/standalone.nix ];
    };
  };

  options.system-parts =
    let
      inherit (lib) types mkOption;
    in
    {
      users = lib.mkOption {
        type = types.attrsOf (
          types.submodule (
            { name, config, ... }:
            {
              options = {
                email = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                firstName = mkOption {
                  type = types.nullOr types.str;
                  default = name;
                };
                lastName = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                fullName = mkOption {
                  type = types.str;
                  default = builtins.concatStringsSep " " (
                    builtins.filter (x: x != null) [
                      config.firstName
                      config.lastName
                    ]
                  );
                };
                sshPublicKeys = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };
              };
            }
          )
        );
      };
    };
}
