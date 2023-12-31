{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.my.nixpkgs;
in {
  _file = ./nixpkgs.nix;

  options.my.nixpkgs = {
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
      _module.args.pkgs = import inputs.nixpkgs (cfg.finalConfig
        // {
          inherit system;
        });
    };
  };

  config = {
    my.nixpkgs.finalConfig = {
      inherit (cfg) overlays config;
    };
    my.nixos.sharedModules = [{nixpkgs = cfg.finalConfig;}];
    my.homeManager.standaloneModules = [{nixpkgs = cfg.finalConfig;}];
  };
}
