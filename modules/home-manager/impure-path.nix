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
  _class = "homeManager";
  options.impurePath = {
    enable = lib.mkEnableOption "impure flake path";

    flakePath = lib.mkOption { type = types.str; };

    remote = lib.mkOption {
      default = null;
      type = types.nullOr (
        types.submodule {
          options = {
            enable = lib.mkEnableOption "setting the remote of the config repo" // {
              default = true;
            };
            name = lib.mkOption {
              type = types.str;
              description = "Name of the remote";
              example = "origin";
            };
            url = lib.mkOption {
              type = types.str;
              description = "URL of the remote";
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."home-manager/flake.nix".source = myLib.mkImpureLink "${self}/flake.nix";
    home.activation = lib.mkIf cfg.enable {
      copyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e ${cfg.flakePath} ]; then
          run cp $VERBOSE_ARG -r ${self} ${cfg.flakePath}
          ${lib.optionalString cfg.remote.enable ''
            run ${lib.getExe config.programs.git.package} -C ${cfg.flakePath} init
            run ${lib.getExe config.programs.git.package} -C ${cfg.flakePath} remote add ${cfg.remote.name} ${cfg.remote.url}
          ''}
        fi
      '';
    };
  };
}
