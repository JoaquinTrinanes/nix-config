{
  lib,
  config,
  inputs,
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
      { system, ... }:
      {
        _module.args.pkgs = lib.mkIf (cfg.input != null) (
          lib.mkDefault (import cfg.input (cfg.finalConfig // { inherit system; }))
        );
      };
    parts = {
      nixpkgs.finalConfig = {
        inherit (cfg) overlays config;
      };
      common.exclusiveModules = [
        {
          _file = ./nixpkgs.nix;
          nixpkgs = cfg.finalConfig;
        }
      ];
      nixos.perHost =
        { system, ... }:
        {
          _file = ./nixpkgs.nix;
          nixpkgs.hostPlatform = lib.mkDefault system;
        };
    };
  };
}
