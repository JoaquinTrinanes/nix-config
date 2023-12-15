{
  self,
  lib,
  config,
  inputs,
  ...
}: let
  pkgs = import inputs.nixpkgs ({system = "x86_64-linux";} // config.nixpkgs);
  inherit (lib) types mkOption mkIf mapAttrs mkEnableOption;
  cfg = config.users;
  homeConfigurations = mapAttrs (_: user:
    mkIf user.homeManager.enable
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [user.homeManager.path];
      extraSpecialArgs = {
        inherit inputs user self;
      };
    })
  cfg;
  inherit (config) hosts;
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
            type = types.submodule ({config, ...}: {
              options = {
                enable = mkEnableOption "home manager for this user";
                path = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                };
                hosts = mkOption {
                  default = {};
                  type = types.submodule ({...}: {
                    options = builtins.mapAttrs (hostName: hostConfig:
                      mkOption {
                        default = config.enable;
                        type = types.oneOf [types.bool (types.listOf types.deferredModule)];
                      })
                    hosts;
                  });
                };
              };
            });
            default = {enabled = false;};
          };
        };
      }));
    };
  };

  config.flake = {
    inherit homeConfigurations;
  };
}
