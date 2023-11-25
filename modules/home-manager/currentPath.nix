{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my;
in {
  options.my = with lib; {
    currentPath = mkOption {
      type = types.nullOr types.str;
      default = "${config.home.homeDirectory}/Documents/nix-config";
    };
    dotfilesUrl = mkOption {
      type = types.nullOr types.str;
      default = "https://github.com/JoaquinTrinanes/nix-config.git";
    };
  };

  config = {
    home.sessionVariables = {FLAKE = cfg.currentPath;};
    home.activation = {
      downloadRepo = lib.hm.dag.entryBefore ["writeBoundary"] (lib.optionalString (cfg.currentPath != null && cfg.dotfilesUrl != null) ''
        if [ ! -e ${cfg.currentPath} ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone $VERBOSE_ARG ${cfg.dotfilesUrl} ${cfg.currentPath}
        fi
      '');
    };
  };
}
