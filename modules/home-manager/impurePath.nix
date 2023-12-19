{
  lib,
  config,
  myLib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkEnableOption mkIf getExe;
  # absPath = p:
  #   if cfg.enable
  #   then
  #     (
  #       let
  #         path = toString p;
  #         strStoreDir = toString ../..;
  #         relativePath = lib.removePrefix "${strStoreDir}/" path;
  #       in
  #         lib.removeSuffix "/" "${cfg.flakePath}/${relativePath}"
  #     )
  #   else toString p;
  # relPath = basePath: path:
  #   removeSuffix "/" (removePrefix "${basePath}/" (absPath path));
  #
  # impurePathType = basePath:
  #   types.attrsOf (types.submodule ({name, ...}: {
  #     options = {
  #       recursive = mkOption {
  #         type = types.bool;
  #         # apply = p: lib.warn "This doesn't do anything" p;
  #         default = false;
  #       };
  #       source = mkOption {
  #         type = types.oneOf [types.path types.str];
  #       };
  #     };
  #   }));
  cfg = config.impurePath;
in {
  options.impurePath = {
    enable = mkEnableOption "impure flake path";
    flakePath = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    repoUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    # configFile = mkOption {
    #   type = impurePathType configHome;
    #   default = {};
    # };
    # file = mkOption {
    #   type = impurePathType homeDirectory;
    #   default = {};
    # };
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

  # config = lib.mkMerge [
  #   # {xdg.configFile."home-manager/flake.nix".source = myLib.mkImpureLink ../../flake.nix;}
  #   (mkIf (!cfg.enable) {
  #     # xdg.configFile = lib.mapAttrs (_: file: file // {source = myLib.mkImpureLink file.source;}) cfg.configFile;
  #     # home.file = lib.mapAttrs (_: file: file // {source = myLib.mkImpureLink file.source;}) cfg.file;
  #     home = {inherit (config.home) file;};
  #     xdg = {inherit (config.xdg) configFile;};
  #   })
  #   (mkIf cfg.enable {
  #     assertions = [
  #       {
  #         assertion = cfg.enable -> cfg.flakePath != null;
  #         message = "Enabling impurePath requires providing a flakePath";
  #       }
  #     ];
  #     systemd.user.tmpfiles.rules = let
  #       mkRule = {
  #         type,
  #         path,
  #         mode ? "-",
  #         user ? "-",
  #         group ? "-",
  #         age ? "-",
  #         argument ? "-",
  #       }: "${type} ${path} ${mode} ${user} ${group} ${age} ${argument}";
  #       mkLink = target: symlinkName:
  #         mkRule {
  #           type = "L+";
  #           path = "%h/${symlinkName}";
  #           argument = "%h/${lib.removePrefix "${homeDirectory}/" (relPath homeDirectory target.source)}";
  #         };
  #     in
  #       lib.mapAttrsToList (path: file: mkLink file path) cfg.file
  #       ++ lib.mapAttrsToList (path: file: mkLink file "${removePrefix "${homeDirectory}/" configHome}/${path}") cfg.configFile;
  #   })
  # ];
}
