{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.system-parts.nixpkgs;
in {
  _file = ./nixpkgs.nix;

  options.system-parts.nixpkgs = {
    overlays = mkOption {
      type = types.listOf types.unspecified;
      default = [];
    };
    config = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.unspecified;
        options = {
          allowUnfree = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
      default = {};
    };
    finalConfig = mkOption {
      type = types.attrsOf types.unspecified;
      readOnly = true;
    };
  };

  config = {
    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs (lib.recursiveUpdate cfg.finalConfig {
        inherit system;
      });
    };
  };

  config = {
    system-parts.nixpkgs.finalConfig = {
      inherit (cfg) overlays config;
    };
    system-parts.common.exclusiveModules = [{nixpkgs = cfg.finalConfig;}];
  };
}
