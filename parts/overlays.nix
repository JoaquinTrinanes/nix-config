{
  self,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
in {
  _file = ./overlays.nix;

  imports = [../overlays];

  options = {
    overlays = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
    };
    enabledOverlays = mkOption {
      type = types.functionTo (types.listOf types.unspecified);
      default = o: [];
    };
  };

  config = {
    nixpkgs.overlays = config.enabledOverlays config.overlays;
    enabledOverlays = o:
      (with o; [
        # additions
        modifications
      ])
      ++ [inputs.nur.overlay];
  };

  config.flake.overlays = config.overlays;
}
