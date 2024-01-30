{
  lib,
  config,
  inputs,
  withSystem,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.my.users;
  inherit (config.my) common homeManager hosts;
in {
  _file = ./users.nix;

  options.my = {
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
            default = null;
          };
          sshPublicKeys = mkOption {
            type = types.listOf types.str;
            default = [];
          };
          u2f = mkOption {
            type = types.listOf (types.submodule ({...}: {
              options = {
                keyHandle = mkOption {type = types.str;};
                userKey = mkOption {type = types.str;};
                coseType = mkOption {type = types.str;};
                options = mkOption {type = types.str;};
              };
            }));
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
          homeManager = mkOption {
            default = {};
            type = types.submodule ({config, ...}: {
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

                hosts = mkOption {
                  type = types.attrsOf (types.submodule ({name, ...}: {
                    options = {
                      enable = mkEnableOption "home manager nixos module on the `${name}` host" // {default = config.enable;};
                      override = mkOption {
                        type = types.functionTo types.deferredModule;
                      };
                    };
                  }));
                  default = {};
                };
              };
              config = {
                finalModules =
                  homeManager.sharedModules
                  ++ config.modules;
              };
            });
          };
        };
      }));
    };
    homeManager = {
      finalConfigurations = mkOption {readOnly = true;};
      sharedModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [];
        description = "List of modules that will be loaded in all home manager configurations";
      };
      standaloneModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [];
        description = "List of modules that will only be loaded in standalone home manager configurations";
      };
    };
  };

  # TODO: changes in this file make standalone modules only be applied to "user" and
  # not to "user@hostname". I guess this is what I want?
  config.my.homeManager.finalConfigurations = let
    users = lib.filterAttrs (_: user: user.homeManager.enable) cfg;
    mkUserConfig = user: {
      extraSpecialArgs = common.specialArgs // {inherit user;};
      modules =
        user.homeManager.finalModules;
    };
    standaloneUserConfig = user: let
      baseConfig = mkUserConfig user;
    in
      (mkUserConfig user) // {modules = baseConfig.modules ++ homeManager.standaloneModules;};

    userHostConfig = user: {
      hostConfig,
      host,
    }: let
      baseConfig = mkUserConfig user;
    in
      inputs.home-manager.lib.homeManagerConfiguration
      (
        {
          inherit (hostConfig) pkgs;
          modules = baseConfig.modules ++ [(host.override host.finalSystem.config)];
        }
        // baseConfig
      );
    allUserConfigs = user:
      {
        ${user.name} = let
          pkgs = withSystem "x86_64-linux" ({pkgs, ...}: pkgs);
        in
          inputs.home-manager.lib.homeManagerConfiguration
          ({inherit pkgs;} // (standaloneUserConfig user));
      }
      // (lib.mapAttrs' (
          hostName: host: (
            lib.nameValuePair "${user.name}@${hostName}" (userHostConfig user {
              inherit host;
              hostConfig = hosts.${hostName}.finalSystem;
            })
          )
        )
        user.homeManager.hosts);
  in
    lib.attrsets.mergeAttrsList (lib.mapAttrsToList (username: allUserConfigs) users);

  config.flake.homeConfigurations = homeManager.finalConfigurations;
}
