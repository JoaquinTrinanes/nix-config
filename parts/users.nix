{
  lib,
  config,
  inputs,
  ...
}: let
  pkgs = import inputs.nixpkgs ({system = "x86_64-linux";} // config.nixpkgs);
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.users;
  inherit (config) nix homeManager;
in {
  _file = ./users.nix;

  options = {
    users = mkOption {
      type = types.attrsOf (types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            readOnly = true;
          };
          email = mkOption {
            type = types.nullOr types.str;
          };
          firstName = mkOption {
            type = types.nullOr types.str;
            default = name;
          };
          lastName = mkOption {
            type = types.nullOr types.str;
          };
          fullName = mkOption {
            type = types.str;
            default = builtins.concatStringsSep " " (builtins.filter (x: x != null) [config.firstName config.lastName]);
          };
          homeManager = mkOption {
            type = types.submodule ({
              name,
              config,
              ...
            }: {
              options = {
                enable = mkEnableOption "home manager for the ${name} user";
                modules = mkOption {
                  type = types.listOf types.deferredModule;
                  default = [];
                };
                finalModules = mkOption {
                  type = types.listOf types.deferredModule;
                  readOnly = true;
                };

                # hostOverrides = lib.mapAttrs (username: user:
                #   mkOption {
                #     type = types.submodule ({
                #       name,
                #       config,
                #       ...
                #     }: {
                #       options = {};
                #     });
                #   })
                # cfg;
              };
              config = {
                finalModules =
                  homeManager.sharedModules
                  ++ config.modules;
              };
            });
            # default = {enable = false;};
          };
        };
      }));
    };
    homeManager = {
      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [];
      };
      standaloneModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [];
      };
    };
  };

  config.flake.homeConfigurations = lib.mapAttrs (_: user: let
    userHmConfig = user.homeManager;
  in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = nix.specialArgs // {inherit user;};
      modules =
        userHmConfig.finalModules ++ homeManager.standaloneModules;
    })
  cfg;
}
