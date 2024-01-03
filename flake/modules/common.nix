{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.my.common;
in {
  _file = ./common.nix;

  options.my.common = {
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
    };
    specialArgs = mkOption {
      type = types.submodule {
        freeformType = types.anything;
      };
    };
    stateVersion = mkOption {type = types.str;};
  };

  config = {
    my.homeManager.sharedModules =
      cfg.modules
      ++ [({lib, ...}: {home.stateVersion = lib.mkDefault cfg.stateVersion;})];
    my.nixos.sharedModules =
      cfg.modules
      ++ [
        ({lib, ...}: {system.stateVersion = lib.mkDefault cfg.stateVersion;})
      ];
  };
}
