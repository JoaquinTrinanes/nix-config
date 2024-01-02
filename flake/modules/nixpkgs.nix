{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.nixpkgs;
in {
  _file = ./nixpkgs.nix;

  options.nixpkgs = {
    overlays = mkOption {
      type = types.listOf types.unspecified;
      default = [];
    };
    config = {
      allowUnfree = mkOption {
        type = types.bool;
        default = true;
      };
    };
    finalConfig = mkOption {
      type = types.lazyAttrsOf types.unspecified;
      readOnly = true;
    };
  };

  config = {
    nixpkgs.finalConfig = {
      inherit (cfg) overlays config;
    };
    nixos.sharedModules = [{nixpkgs = cfg.finalConfig;}];
    homeManager.standaloneModules = [{nixpkgs = cfg.finalConfig;}];

    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (cfg) overlays config;
      };
    };
  };
}
