{ lib, config, ... }:
let
  inherit (lib) types;
  cfg = config.impurePath;
  absPath =
    p:
    let
      path = toString p;
      strStoreDir = toString cfg.self;
      relativePath = lib.removePrefix "${strStoreDir}/" path;
    in
    if config.impurePath.enable then
      lib.removeSuffix "/" "${config.impurePath.flakePath}/${relativePath}"
    else
      relativePath;
  mkImpureLink =
    path:
    config.lib.file.mkOutOfStoreSymlink (
      if config.impurePath.enable then
        (config.lib.impurePath.absPath path)
      else
        lib.warn "impurePath is disabled, symlinks will point to store files" path
    );
in
{
  _class = "homeManager";
  options.impurePath = {
    enable = lib.mkEnableOption "impure flake path";

    flakePath = lib.mkOption { type = types.path; };

    self = lib.mkOption { type = types.path; };

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

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      xdg.configFile."home-manager/flake.nix".source = mkImpureLink "${cfg.self}/flake.nix";
      # home.activation = lib.mkIf cfg.enable {
      #   copyConfig =
      #     lib.hm.dag.entryAfter [ "writeBoundary" ]
      #       # bash
      #       ''
      #         if [ ! -e ${cfg.flakePath} ]; then
      #           run cp $VERBOSE_ARG -r ${cfg.self} ${cfg.flakePath}
      #           ${lib.optionalString cfg.remote.enable ''
      #             run ${lib.getExe config.programs.git.package} -C ${cfg.flakePath} init
      #             run ${lib.getExe config.programs.git.package} -C ${cfg.flakePath} remote add ${cfg.remote.name} ${cfg.remote.url}
      #           ''}
      #         fi
      #       '';
      # };
    })
    {
      lib.impurePath = {
        inherit mkImpureLink absPath;
      };
    }
  ];
}
