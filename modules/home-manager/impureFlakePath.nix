{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkEnableOption mkIf hasPrefix removePrefix;
  inherit (config.home) homeDirectory;
  inherit (config.xdg) configHome;
  # fileType = basePath:
  # types.attrsOf (types.submodule (
  #   {
  #     name,
  #     config,
  #     ...
  #   }: {
  #     options = {
  #       enable = mkOption {
  #         type = types.bool;
  #         default = true;
  #         description = ''
  #           Whether this file should be generated. This option allows specific
  #           files to be disabled.
  #         '';
  #       };
  #       target = mkOption {
  #         type = types.str;
  #         apply = p: let
  #           absPath =
  #             if hasPrefix "/" p
  #             then p
  #             else "${basePath}/${p}";
  #         in
  #           removePrefix (homeDirectory + "/") absPath;
  #         defaultText = literalExpression "name";
  #       };
  #
  #       text = mkOption {
  #         default = null;
  #         type = types.nullOr types.lines;
  #         description = ''
  #           Text of the file. If this option is null then {var}`source`
  #           must be set.
  #         '';
  #       };
  #
  #       source = mkOption {
  #         type = types.path;
  #         description = ''
  #           Path of the source file or directory. If {var}`text`
  #           is non-null then this option will automatically
  #           point to a file containing that text.
  #         '';
  #       };
  #
  #       executable = mkOption {
  #         type = types.nullOr types.bool;
  #         default = null;
  #         description = ''
  #           Set the execute bit. If `null`, defaults to the mode
  #           of the {var}`source` file or to `false`
  #           for files created through the {var}`text` option.
  #         '';
  #       };
  #
  #       recursive = mkOption {
  #         type = types.bool;
  #         default = false;
  #         description = ''
  #           If the file source is a directory, then this option
  #           determines whether the directory should be recursively
  #           linked to the target location. This option has no effect
  #           if the source is a file.
  #
  #           If `false` (the default) then the target
  #           will be a symbolic link to the source directory. If
  #           `true` then the target will be a
  #           directory structure matching the source's but whose leafs
  #           are symbolic links to the files of the source directory.
  #         '';
  #       };
  #
  #       onChange = mkOption {
  #         type = types.lines;
  #         default = "";
  #         description = ''
  #           Shell commands to run when file has changed between
  #           generations. The script will be run
  #           *after* the new files have been linked
  #           into place.
  #
  #           Note, this code is always run when `recursive` is
  #           enabled.
  #         '';
  #       };
  #
  #       force = mkOption {
  #         type = types.bool;
  #         default = false;
  #         visible = false;
  #         description = ''
  #           Whether the target path should be unconditionally replaced
  #           by the managed file source. Warning, this will silently
  #           delete the target regardless of whether it is a file or
  #           link.
  #         '';
  #       };
  #     };
  #
  #     config = {
  #       target = mkDefault name;
  #       source = mkIf (config.text != null) (
  #         mkDefault (pkgs.writeTextFile {
  #           inherit (config) text;
  #           executable = config.executable == true; # can be null
  #           name = hm.strings.storeFileName name;
  #         })
  #       );
  #     };
  #   }
  # ));
  # impurePathType = basePath: types.attrsOf (types.submodule ({name,...}:{}))
  homeRelPath = basePath: path: let
    absPath =
      if hasPrefix "/" path
      then path
      else "${basePath}/${path}";
  in
    removePrefix "${homeDirectory}/" absPath;

  impurePathType = basePath:
    types.attrsOf (types.submodule ({name, ...}: {
      options = {
        source = mkOption {
          type = types.str;
          apply = homeRelPath basePath;
        };
      };
    }));
  # impurePathOption = basePath = mkOption {type=impurePathType basePath;};
  cfg = config.impureFlakePath;
in {
  options.impureFlakePath = {
    enable = mkEnableOption "impure flake path";
    flakePath = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    url = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    configFile = mkOption {
      type = impurePathType configHome; # types.attrsOf types.string;
      # type = fileType configHome;
      default = {};
    };
    file = mkOption {
      type = impurePathType homeDirectory; # types.attrsOf types.string;
      # type = fileType homeDirectory;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> cfg.flakePath != null;
        message = "What";
      }
    ];
    systemd.user.tmpfiles.rules = let
      mkLink = target: symlinkName: "L+ %h/${symlinkName} - - - - %h/${lib.removePrefix "${homeDirectory}/" target}";
    in
      [
        (mkLink "${cfg.flakePath}/flake.nix" ".config/home-manager/flake.nix")
        # "L+ %h/.config/home-manager/flake.nix - - - - ${cfg.path}/flake.nix"
      ]
      ++ lib.mapAttrsToList (path: file: mkLink file.source (homeRelPath homeDirectory path)) cfg.file
      ++ lib.mapAttrsToList (path: file: mkLink file.source (homeRelPath configHome path)) cfg.configFile;
  };
}
