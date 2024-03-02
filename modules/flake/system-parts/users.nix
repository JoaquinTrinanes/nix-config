{
  lib,
  config,
  inputs,
  withSystem,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.system-parts.users;
  inherit (config.system-parts) common homeManager hosts;
  u2fKeyType = types.submodule {
    options = {
      keyHandle = mkOption {type = types.str;};
      userKey = mkOption {type = types.str;};
      coseType = mkOption {type = types.str;};
      options = mkOption {type = types.str;};
    };
  };
  mkHomeManagerOption = user: let
    username = user.name;
  in
    mkOption {
      default = {};
      type = types.submodule ({config, ...}: {
        options = {
          enable = mkEnableOption "home manager for the ${username} user";
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          finalModules = mkOption {
            type = types.listOf types.deferredModule;
            readOnly = true;
          };

          hosts = mkOption {
            type = types.attrsOf (types.submodule ({name, ...}: {
              options = {
                enable = mkEnableOption "home manager nixos module on the `${name}` host" // {default = config.enable;};
                override = mkOption {
                  type = types.functionTo types.deferredModule;
                  default = _osConfig: {};
                };
              };
            }));
            default = {};
          };
          finalConfigurations = mkOption {
            readOnly = true;
            type = types.attrsOf types.unspecified;
          };
        };
        config = {
          finalModules =
            homeManager.modules
            ++ config.modules;

          finalConfigurations = let
            baseConfig = {
              # TODO: user as an option instead of arg
              extraSpecialArgs = common.specialArgs // {inherit user;};
              modules = config.finalModules;
            };
            standaloneConfig =
              baseConfig
              // {
                modules = baseConfig.modules ++ homeManager.standaloneModules;
                pkgs = withSystem "x86_64-linux" ({pkgs, ...}: pkgs);
              };
            hostConfigs =
              lib.mapAttrs' (
                hostName: {
                  enable,
                  override,
                }: let
                  host = hosts.${hostName}.finalSystem;
                in
                  lib.nameValuePair "${username}@${hostName}"
                  (lib.mkIf enable (baseConfig
                    // {
                      inherit (host) pkgs;
                      modules =
                        baseConfig.modules
                        ++ [(override host.config)];
                    }))
              )
              user.homeManager.hosts;
          in
            lib.mkMerge [
              (lib.mkIf config.enable {
                ${username} = standaloneConfig;
              })
              hostConfigs
            ];
        };
      });
    };
  userType = types.submodule ({
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
        default = null;
      };
      sshPublicKeys = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      u2f = mkOption {
        type = types.listOf u2fKeyType;
        default = [];
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
        default = builtins.concatStringsSep " " (builtins.filter (x: x != null) [config.firstName config.lastName]);
      };
      homeManager = mkHomeManagerOption config;
    };
  });
in {
  _file = ./users.nix;

  options.system-parts = {
    users = mkOption {
      # TODO: set this option for home manager, remove it from specialArgs
      type = types.attrsOf userType;
      # TODO: might be valuable to set some fields in the config. And make the whole thing optional?
      readOnly = true;
    };
    homeManager = mkOption {
      type = types.submodule ({lib, ...}: {
        options = {
          finalConfigurations = mkOption {readOnly = true;};
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
            description = "Modules that will be loaded in all home manager configurations";
          };
          standaloneModules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
            description = "Modules that will only be loaded in standalone home manager configurations";
          };
        };

        config.finalConfigurations = lib.mkMerge (lib.mapAttrsToList (_: value: value.homeManager.finalConfigurations) cfg);
      });
    };
  };

  config = {
    flake.homeConfigurations = lib.mapAttrs (_: inputs.home-manager.lib.homeManagerConfiguration) homeManager.finalConfigurations;
  };
}
