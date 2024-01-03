{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.my.overlays;
in {
  _file = ./overlays.nix;

  options.my.overlays = {
    all = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
    };
    enabled = mkOption {
      type = types.functionTo (types.listOf types.unspecified);
      default = _: [];
    };
    final = mkOption {
      type = types.listOf types.unspecified;
      readOnly = true;
    };
  };

  config.my = {
    overlays.final = cfg.enabled cfg.all;
    nixpkgs.overlays = cfg.final;
  };

  config.flake.overlays = cfg.all;
}
