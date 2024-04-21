{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.system-parts.nixos;
  inherit (config.system-parts) users common;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg.hosts;
  inherit (lib) types mkOption mkIf;
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
          default = inputs.nixpkgs;
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
          type = types.attrsOf types.unspecified;
          default = { };
        };
      };

      config = {
        finalModules =
          cfg.modules
          ++ [ { networking.hostName = lib.mkDefault config.name; } ]
          ++ config.modules
          ++ [ (cfg.perHost config) ]
          ++ lib.mapAttrsToList (
            username: user:
            mkIf (user.homeManager.hosts.${name}.enable or false) {
              imports = [ inputs.home-manager.nixosModules.home-manager ];
              home-manager = {
                users."${user.name}" = {
                  imports = user.homeManager.finalModules ++ [
                    (user.homeManager.hosts.${name}.override config.finalSystem)
                  ];
                };
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = lib.recursiveUpdate common.specialArgs config.specialArgs;
              };
            }
          ) users;

        finalSystem = config.nixpkgs.lib.nixosSystem {
          modules = config.finalModules;
          inherit (common) specialArgs;
        };
      };
    }
  );
in
{
  options.system-parts.nixos = {
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
      type = types.attrsOf hostType;
      default = { };
    };
  };

  config = {
    flake = {
      nixosConfigurations = configs;
    };
  };
}
