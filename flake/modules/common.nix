{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.common;
in {
  _file = ./.;

  options.common = {
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
    homeManager.sharedModules =
      cfg.modules
      ++ [({lib, ...}: {home.stateVersion = lib.mkDefault cfg.stateVersion;})];
    nixos.sharedModules =
      cfg.modules
      ++ [
        ({lib, ...}: {system.stateVersion = lib.mkDefault cfg.stateVersion;})
      ];
  };
}
