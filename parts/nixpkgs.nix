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
  };

  config = {
    nixos.sharedModules = [{nixpkgs = cfg;}];
    homeManager.standaloneModules = [{nixpkgs = cfg;}];

    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs ({inherit system;} // cfg);
    };
  };
}
