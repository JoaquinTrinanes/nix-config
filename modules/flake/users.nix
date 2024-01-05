{
  lib,
  config,
  inputs,
  ...
}: let
  pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.my.users;
  inherit (config.my) common homeManager;
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
                      override = mkOption {type = types.functionTo types.deferredModule;};
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

  config.my.homeManager.finalConfigurations = let
    users = lib.filterAttrs (_: user: user.homeManager.enable) cfg;
    mkUserConfig = user:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = common.specialArgs // {inherit user;};
        modules =
          user.homeManager.finalModules ++ homeManager.standaloneModules;
      };
    userHostConfig = user: host: let
      userConfig = mkUserConfig user;
    in
      userConfig
      // {
        modules = userConfig.modules ++ [(host.override host.finalSystem.config)];
      };
    userFullConfig = user: {${user.name} = mkUserConfig user;} // (lib.mapAttrs' (hostName: host: lib.nameValuePair "${user.name}@${hostName}" (userHostConfig user host)) user.homeManager.hosts);
  in
    lib.attrsets.mergeAttrsList (lib.mapAttrsToList (username: userFullConfig) users);

  config.flake.homeConfigurations = homeManager.finalConfigurations;
}
