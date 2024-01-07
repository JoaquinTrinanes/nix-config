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
      description = "Modules that are loaded in all hosts and home manager configurations";
    };
    specialArgs = mkOption {
      type = types.attrsOf types.unspecified;
      description = "Special args passed to all hosts and home manager configurations";
      default = {};
    };
    stateVersion = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default state version";
    };
  };

  config = let
    stateVersion = lib.mkIf (cfg.stateVersion != null) (lib.mkDefault cfg.stateVersion);
  in {
    my.homeManager.sharedModules =
      cfg.modules
      ++ [{home = {inherit stateVersion;};}];
    my.nixos.sharedModules =
      cfg.modules
      ++ [
        {system = {inherit stateVersion;};}
      ];
  };
}
