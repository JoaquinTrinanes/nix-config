{
  lib,
  config,
  inputs,
  withSystem,
  ...
}:
let
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.system-parts.users;
  inherit (config.system-parts) common home-manager nixos;
  specialArgsOption = mkOption {
    type = types.attrsOf types.unspecified;
    default = { };
  };
  mkHomeManagerUserConfigType =
    user:
    types.submodule (
      { config, ... }:
      {
        options = {
          enable = (mkEnableOption "home manager for the ${user.name} user") // {
            default = true;
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [ ];
          };
          finalModules = mkOption {
            type = types.listOf types.deferredModule;
            readOnly = true;
          };
          specialArgs = specialArgsOption;
          hosts = mkOption {
            type = types.attrsOf (
              types.submodule (
                { name, ... }:
                {
                  options = {
                    enable = (mkEnableOption "home manager nixos module on the `${name}` host") // {
                      default = config.enable;
                    };
                    override = mkOption {
                      type = types.functionTo types.deferredModule;
                      default = _osConfig: { };
                    };
                  };
                }
              )
            );
            default = { };
          };
          finalConfigurations = mkOption {
            readOnly = true;
            type = types.attrsOf types.unspecified;
          };
        };
        config = {
          finalModules = lib.mkMerge [
            home-manager.modules
            config.modules
            (lib.mkIf (home-manager.perUser != null) [ (home-manager.perUser user) ])
          ];

          finalConfigurations =
            let
              baseConfig =
                let
                  recursiveUpdateList = lib.foldl (a: b: lib.recursiveUpdate a b) { };
                in
                {
                  extraSpecialArgs = recursiveUpdateList [
                    common.specialArgs
                    home-manager.specialArgs
                    config.specialArgs
                  ];
                  modules = config.finalModules;
                };
              standaloneConfig = lib.recursiveUpdate baseConfig {
                modules = baseConfig.modules ++ home-manager.standaloneModules;
                pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
              };
              hostConfigs = lib.mapAttrs' (
                hostName:
                { enable, override }:
                let
                  host = nixos.hosts.${hostName}.finalSystem;
                in
                lib.nameValuePair "${user.name}@${hostName}" (
                  lib.mkIf enable (
                    lib.recursiveUpdate baseConfig {
                      inherit (host) pkgs;
                      modules = baseConfig.modules ++ [ (override host.config) ];
                    }
                  )
                )
              ) user.home-manager.hosts;
            in
            lib.mkMerge [
              (lib.mkIf config.enable { ${user.name} = standaloneConfig; })
              hostConfigs
            ];
        };
      }
    );
  userType = types.submodule (
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        home-manager = mkOption {
          type = mkHomeManagerUserConfigType config;
          default = { };
        };
      };
    }
  );
in
{
  options.system-parts = {
    users = mkOption {
      type = types.attrsOf userType;
      default = { };
    };
    home-manager = mkOption {
      type = types.submodule (
        { lib, ... }:
        {
          options = {
            perUser = mkOption {
              type = types.nullOr (types.functionTo types.deferredModule);
              description = "Function that takes a user as an argument and returns a home manager module.";
              default = null;
            };
            specialArgs = specialArgsOption;
            finalConfigurations = mkOption { readOnly = true; };
            modules = mkOption {
              type = types.listOf types.deferredModule;
              default = [ ];
              description = "Modules that will be loaded in all home manager configurations";
            };
            standaloneModules = mkOption {
              type = types.listOf types.deferredModule;
              default = [ ];
              description = "Modules that will only be loaded in standalone home manager configurations";
            };
          };

          config.finalConfigurations = lib.mkMerge (
            lib.mapAttrsToList (_: value: value.home-manager.finalConfigurations) cfg
          );
        }
      );
    };
  };

  config = {
    flake.homeConfigurations = lib.mapAttrs (
      _: inputs.home-manager.lib.homeManagerConfiguration
    ) home-manager.finalConfigurations;
  };
}
