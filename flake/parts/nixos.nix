{
  lib,
  config,
  withSystem,
  ...
}:
let
  cfg = config.parts.nixos;
  inherit (config.parts) common nixpkgs;
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
          type = types.attrsOf types.unspecified;
          default = { };
        };
        extraArgs = mkOption {
          type = types.attrsOf types.unspecified;
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
        ];

        finalSystem = withSystem config.system (
          { lib, ... }:
          lib.nixosSystem (
            lib.recursiveUpdate {
              modules = config.finalModules;
              inherit (common) specialArgs;
            } config.extraArgs
          )
        );
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
