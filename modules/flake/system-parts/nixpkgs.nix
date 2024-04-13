{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.system-parts.nixpkgs;
in
{
  options.system-parts.nixpkgs = {
    input = mkOption {
      default = inputs.nixpkgs or null;
      defaultText = lib.literalExpression "inputs.nixpkgs or null";
      type = types.nullOr (types.addCheck (types.attrsOf types.unspecified) (types.isType "flake"));
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
          lib.mkDefault (import cfg.input (lib.recursiveUpdate { inherit system; } cfg.finalConfig))
        );
      };

    system-parts.nixpkgs.finalConfig = {
      inherit (cfg) overlays config;
    };
    system-parts.common.exclusiveModules = [ { nixpkgs = cfg.finalConfig; } ];
  };
}
