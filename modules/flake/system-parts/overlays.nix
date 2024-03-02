{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.system-parts.overlays;
in {
  _file = ./overlays.nix;

  options.system-parts.overlays = {
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

  config.system-parts = {
    overlays.final = cfg.enabled cfg.all;
    nixpkgs.overlays = cfg.final;
  };

  config.flake.overlays = cfg.all;
}
