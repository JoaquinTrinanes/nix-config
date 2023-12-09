{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.currentPath;
  inherit (lib) mkOption types mkEnableOption mkIf;
in {
  options.currentPath = {
    enable = (mkEnableOption "current path") // {default = true;};
    source = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Documents/nix-config";
    };
    dotfilesUrl = mkOption {
      type = types.nullOr types.str;
      default = "https://github.com/JoaquinTrinanes/nix-config.git";
    };
  };

  config = mkIf cfg.enable {
    home.activation = mkIf (cfg.dotfilesUrl != null) {
      downloadRepo = lib.hm.dag.entryBefore ["writeBoundary"] (lib.optionalString (cfg.source != null && cfg.dotfilesUrl != null) ''
        if [ ! -e ${cfg.source} ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone $VERBOSE_ARG ${cfg.dotfilesUrl} ${cfg.source}
        fi
      '');
    };
  };
}
