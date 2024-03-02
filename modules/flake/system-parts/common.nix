{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.system-parts.common;
in {
  _file = ./common.nix;

  options.system-parts.common = {
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "Modules that are loaded in all hosts and home manager configurations";
    };
    exclusiveModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "Modules that are loaded in either standalone home manager configurations or host configurations";
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
    system-parts.homeManager = {
      standaloneModules = cfg.exclusiveModules;
      modules =
        cfg.modules
        ++ [{home = {inherit stateVersion;};}];
    };

    system-parts.nixos.modules =
      cfg.modules
      ++ cfg.exclusiveModules
      ++ [
        {system = {inherit stateVersion;};}
      ];
  };
}
