{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.parts.common;
in
{
  options.parts.common = {
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      description = "Modules that are loaded in all hosts and home manager configurations";
    };

    exclusiveModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ];
      description = "Modules that are loaded in either standalone home manager configurations or host configurations";
    };

    specialArgs = mkOption {
      type = types.attrsOf types.unspecified;
      description = "Special args passed to all hosts and home manager configurations";
      default = { };
    };
  };

  config = {
    parts.home-manager = {
      inherit (cfg) modules;
      standaloneModules = cfg.exclusiveModules;
    };

    parts.nixos.modules = lib.mkMerge [
      cfg.modules
      cfg.exclusiveModules
    ];
  };
}
