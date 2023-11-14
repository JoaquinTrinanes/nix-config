{
  lib,
  config,
  pkgs,
  ...
}: {
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
    home.activation = {
      downloadRepo = lib.hm.dag.entryBefore ["writeBoundary"] (lib.optionalString (config.my.currentPath != null && config.my.dotfilesUrl != null) ''
        if [ ! -e ${config.my.currentPath} ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone $VERBOSE_ARG ${config.my.dotfilesUrl} ${config.my.currentPath}
        fi
      '');
    };
  };
}
