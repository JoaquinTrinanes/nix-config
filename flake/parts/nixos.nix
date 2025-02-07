{
  lib,
  config,
  ...
}:
let
  cfg = config.parts.nixos;
  inherit (config.parts)
    common
    home-manager
    nixpkgs
    users
    ;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg.hosts;
  inherit (lib) types mkOption;
  hostType = types.submodule (
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        nixpkgs = mkOption {
          type = types.unspecified;
          default = nixpkgs.input;
          description = "Instance of nixpkgs";
        };
        modules = mkOption {
          type = types.listOf types.deferredModule;
          default = [ ];
          description = "Modules for this host";
        };
        system = mkOption { type = types.enum config.nixpkgs.lib.systems.flakeExposed; };
        finalModules = mkOption {
          type = types.listOf types.unspecified;
          readOnly = true;
        };
        finalSystem = mkOption {
          type = types.unspecified;
          readOnly = true;
        };
        specialArgs = mkOption {
          type = types.lazyAttrsOf types.unspecified;
          default = { };
        };
      };

      config = {
        finalModules = lib.mkMerge [
          cfg.modules
          [
            {
              _file = ./nixos.nix;
              networking.hostName = lib.mkDefault config.name;
            }
          ]
          config.modules
          [ (cfg.perHost config) ]
          (lib.mapAttrsToList (
            userName: userConfig:
            let
              userHostConfig = userConfig.home-manager.hosts.${config.name} or { };
            in
            lib.mkIf (userHostConfig.enable or userConfig.home-manager.enable) {
              _file = ./nixos.nix;
              imports = [ home-manager.input.nixosModules.home-manager ];
              users.users."${userName}" = {
                isNormalUser = lib.mkDefault true;
              };
              home-manager = {
                users."${userName}" = {
                  imports = userConfig.home-manager.finalModules ++ userHostConfig.modules or [ ];
                };
                useUserPackages = lib.mkDefault true;
                useGlobalPkgs = lib.mkDefault true;
                extraSpecialArgs = lib.recursiveUpdate common.specialArgs userConfig.home-manager.specialArgs;
              };
            }
          ) users)
        ];

        finalSystem = lib.nixosSystem {
          modules = config.finalModules;
          inherit (common) specialArgs;
        };
      };
    }
  );
in
{
  options.parts.nixos = {
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      description = "Modules shared across all nixos configurations";
    };
    perHost = mkOption {
      type = types.nullOr (types.functionTo types.deferredModule);
      description = "Function that takes a host as an argument and returns a nixos module.";
      default = _: { };
    };
    hosts = mkOption {
      description = "Host configurations";
      type = types.lazyAttrsOf hostType;
      default = { };
    };
  };

  config = {
    flake = {
      nixosConfigurations = configs;
    };
  };
}
