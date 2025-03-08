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
    if config.impurePath.enable then
      config.lib.file.mkOutOfStoreSymlink (
        cfg.flakePath + lib.removePrefix (toString cfg.self) (toString path)
      )
    else
      lib.warn "impurePath is disabled, symlinks will point to store files" path;
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
      home.activation = lib.mkIf cfg.enable {
        copyConfig =
          let
            git = "${lib.getExe config.programs.git.package} -C ${lib.escapeShellArg cfg.flakePath}";
            relativeFlakePath = "${lib.removePrefix "${config.home.homeDirectory}/" cfg.flakePath}";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ]
            # bash
            ''
              if [ ! -e ${relativeFlakePath} ]; then
                run mkdir $VERBOSE_ARG -m 0755 -p "$(dirname ${relativeFlakePath})"
                run cp $VERBOSE_ARG -r ${lib.escapeShellArg cfg.self} ${lib.escapeShellArg cfg.flakePath}
                # Will mess up the permissions, but at least the correct files will be in the expected place since the start (and not readonly)
                run chmod $VERBOSE_ARG -R 0755 ${lib.escapeShellArg relativeFlakePath}
                ${lib.optionalString cfg.remote.enable ''
                  run ${git} init
                  run ${git} remote add ${lib.escapeShellArg cfg.remote.name} ${lib.escapeShellArg cfg.remote.url}
                  # run ${git} branch --set-upstream-to=origin/HEAD
                ''}
              fi
            '';
      };
    })
    {
      lib.impurePath = {
        inherit mkImpureLink absPath;
      };
    }
  ];
}
