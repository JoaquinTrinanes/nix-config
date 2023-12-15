{
  self,
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
      default =
        (builtins.attrValues {
          inherit
            (self.overlays)
            additions
            modifications
            ;
        })
        ++ [inputs.nur.overlay];
    };
    config = {
      allowUnfree = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config.perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs (cfg // {inherit system;});
  };
}
