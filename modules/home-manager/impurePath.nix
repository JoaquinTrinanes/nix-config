{
  lib,
  config,
  myLib,
  self,
  ...
}:
let
  inherit (lib) types;
  cfg = config.impurePath;
in
{
  options.impurePath = {
    enable = lib.mkEnableOption "impure flake path" // {
      default = cfg.flakePath != null;
    };
    flakePath = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    repoUrl = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."home-manager/flake.nix".source = myLib.mkImpureLink "${self}/flake.nix";
    home.activation = lib.mkIf (cfg.repoUrl != null && cfg.flakePath != null) {
      downloadRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e ${cfg.flakePath} ]; then
          run ${lib.getExe config.programs.git.package} clone $VERBOSE_ARG ${cfg.repoUrl} ${cfg.flakePath}
        fi
      '';
    };
  };
}
