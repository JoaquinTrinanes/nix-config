{
  lib,
  config,
  inputs,
  withSystem,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.parts.nixpkgs;
in
{
  options.parts.nixpkgs = {
    enable = mkEnableOption "nixpkgs management";
    input = mkOption {
      type = types.addCheck (types.attrsOf types.unspecified) (types.isType "flake");
      default = inputs.nixpkgs;
      defaultText = lib.literalExpression "inputs.nixpkgs";
    };
    overlays = mkOption {
      type = types.listOf types.unspecified;
      default = [ ];
    };
    config = mkOption {
      type = types.attrsOf types.unspecified;
      default = { };
    };
    finalConfig = mkOption {
      type = types.attrsOf types.unspecified;
      readOnly = true;
    };
  };

  config = {
    perSystem =
      { system, lib, ... }:
      {
        _module.args.pkgs = lib.mkIf (cfg.input != null) (
          lib.mkDefault (import cfg.input (cfg.finalConfig // { inherit system; }))
        );
      };
    parts = {
      nixpkgs.finalConfig = {
        inherit (cfg) overlays config;
      };
      # Standalone home-manager configurations instantiate their own nixpkgs
      home-manager.standaloneModules = [
        {
          _file = ./nixpkgs.nix;
          nixpkgs = cfg.finalConfig;
        }
      ];
      # NixOS reuses the perSystem instance instead of importing nixpkgs again, so the system
      # and `self.packages` share one evaluation. `nixpkgs.config` must then stay empty in NixOS
      # modules (enforced by an assertion): configure nixpkgs through `parts.nixpkgs` instead.
      nixos.perHost =
        { system, ... }:
        {
          _file = ./nixpkgs.nix;
          nixpkgs.hostPlatform = lib.mkDefault system;
          nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
        };
    };
  };
}
