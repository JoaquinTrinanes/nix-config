{
  lib,
  config,
  withSystem,
  inputs,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.parts.users;
  inherit (config.parts)
    common
    home-manager
    nixos
    nixpkgs
    ;
  specialArgsOption = mkOption {
    type = types.lazyAttrsOf types.unspecified;
    default = { };
  };
  mkHomeManagerUserConfigType =
    # TODO: remove extra home-manager nesting level, move one level out into parts.users.<user>.modules...
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
            type = types.lazyAttrsOf (
              types.submodule (
                { name, ... }:
                {
                  options = {
                    enable = (mkEnableOption "home manager nixos module on the `${name}` host") // {
                      default = config.enable;
                    };
                    modules = mkOption {
                      type = types.listOf types.deferredModule;
                      default = [ ];
                    };
                  };
                }
              )
            );
            default = { };
          };
          finalConfigurations = mkOption {
            readOnly = true;
            type = types.lazyAttrsOf types.unspecified;
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
              standaloneConfig = lib.recursiveUpdate baseConfig (
                withSystem "x86_64-linux" (
                  { system, lib, ... }:
                  {
                    modules = baseConfig.modules ++ home-manager.standaloneModules;
                    pkgs = nixpkgs.input.legacyPackages.${system};
                    inherit lib;
                  }
                )
              );
              hostConfigs = lib.mapAttrs' (
                hostName:
                { enable, modules }:
                let
                  host = nixos.hosts.${hostName}.finalSystem;
                in
                lib.nameValuePair "${user.name}@${hostName}" (
                  lib.mkIf enable (
                    lib.recursiveUpdate baseConfig (
                      withSystem host.pkgs.stdenv.hostPlatform.system (
                        { lib, ... }:
                        {
                          inherit (host) pkgs;
                          modules = baseConfig.modules ++ modules;
                          extraSpecialArgs.osConfig = host.config;
                          inherit lib;
                        }
                      )
                    )
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
        sshPublicKeys = mkOption {
          type = types.listOf types.str;
          default = [ ];
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
  options.parts = {
    users = mkOption {
      type = types.lazyAttrsOf userType;
      default = { };
    };
    home-manager = mkOption {
      type = types.submodule (
        { lib, ... }:
        {
          options = {
            input = mkOption {
              type = types.addCheck (types.attrsOf types.unspecified) (types.isType "flake");
              default = inputs.home-manager;
              defaultText = lib.literalExpression "inputs.home-manager";

            };
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

  options.flake = flake-parts-lib.mkSubmoduleOptions {
    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''Instantiated Home-Manager configurations.'';
      example = lib.literalExpression ''{ "user@host" = inputs.home-manager.lib.homeManagerConfiguration { .. }; }'';
    };
  };

  config = {
    parts.nixos.hosts = lib.mkMerge (
      lib.mapAttrsToList (
        userName: userCfg:
        let
          hostConfig = userCfg.home-manager.hosts;
        in
        lib.mkMerge (
          lib.mapAttrsToList (
            hostName:
            { modules, enable }:
            lib.mkIf enable {
              ${hostName}.modules = [
                {
                  _file = ./users.nix;
                  imports = [ home-manager.input.nixosModules.home-manager ];
                  home-manager = {
                    users."${userName}" = {
                      imports = userCfg.home-manager.finalModules ++ modules;
                    };
                    useUserPackages = lib.mkDefault true;
                    useGlobalPkgs = lib.mkDefault true;
                    extraSpecialArgs = lib.recursiveUpdate common.specialArgs userCfg.home-manager.specialArgs;
                  };
                }
              ];
            }
          ) hostConfig
        )
      ) cfg
    );
    flake.homeConfigurations = lib.mapAttrs (
      _: home-manager.input.lib.homeManagerConfiguration
    ) home-manager.finalConfigurations;
  };
}
