{
  lib,
  config,
  myLib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkEnableOption mkIf getExe;
  cfg = config.my.impurePath;
in {
  options.my.impurePath = {
    enable = mkEnableOption "impure flake path";
    flakePath = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    repoUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."home-manager/flake.nix".source = myLib.mkImpureLink ../../flake.nix;
    home.activation = mkIf (cfg.repoUrl != null && cfg.flakePath != null) {
      downloadRepo = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -e ${cfg.flakePath} ]; then
          $DRY_RUN_CMD ${getExe pkgs.git} clone $VERBOSE_ARG ${cfg.repoUrl} ${cfg.flakePath}
        fi
      '';
    };
  };
}
