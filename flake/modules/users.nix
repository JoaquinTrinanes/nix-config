{
  lib,
  config,
  inputs,
  ...
}: let
  pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.users;
  inherit (config) nix homeManager hosts;
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

                hostOverrides = lib.mapAttrs (host: override:
                  mkOption {
                    type = types.nullOr (types.functionTo types.deferredModule);
                    default = null;
                  })
                hosts;
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
      };
      standaloneModules = mkOption {
        type = types.listOf types.deferredModule;
        default = [];
      };
    };
  };

  config.homeManager.finalConfigurations = let
    mkUserConfig = user: {
      inherit pkgs;
      extraSpecialArgs = nix.specialArgs // {inherit user;};
      modules =
        user.homeManager.finalModules ++ homeManager.standaloneModules;
    };
    userConfigs =
      lib.mapAttrs (_: user: (mkUserConfig user))
      cfg;
    userHostConfigs = user:
      lib.mapAttrs' (
        host: config: let
          module = user.homeManager.hostOverrides.${host};
        in
          lib.nameValuePair "${user.name}@${host}"
          (userConfigs.${user.name}
            // {
              modules =
                userConfigs.${user.name}.modules
                ++ [(module hosts.${host}.finalSystem.config)];
            })
      )
      (lib.filterAttrs (_: v: v != null) user.homeManager.hostOverrides);
    userConfigWithHosts = user: ((userHostConfigs user) // {${user.name} = userConfigs.${user.name};});
    allUsersConfigs = lib.attrsets.mergeAttrsList (builtins.map userConfigWithHosts (lib.attrValues cfg));
  in
    lib.mapAttrs (_: userConfig: (inputs.home-manager.lib.homeManagerConfiguration userConfig))
    allUsersConfigs;

  config.flake.homeConfigurations = homeManager.finalConfigurations;
}
