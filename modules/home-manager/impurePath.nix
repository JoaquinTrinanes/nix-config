{
  lib,
  config,
  myLib,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkOption types mkEnableOption mkIf getExe;
  cfg = config.impurePath;
in {
  options.impurePath = {
    enable = mkEnableOption "impure flake path" // {default = cfg.flakePath != null;};
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
    xdg.configFile."home-manager/flake.nix".source = myLib.mkImpureLink "${self}/flake.nix";
    home.activation = mkIf (cfg.repoUrl != null && cfg.flakePath != null) {
      downloadRepo = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -e ${cfg.flakePath} ]; then
          $DRY_RUN_CMD ${getExe pkgs.git} clone $VERBOSE_ARG ${cfg.repoUrl} ${cfg.flakePath}
        fi
      '';
    };
  };
}
