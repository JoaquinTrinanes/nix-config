{ lib, config, ... }:
let
  cfg = config.profiles.jellyfin;
  inherit (lib) types;
in
{
  options.profiles.jellyfin = {
    enable = lib.mkEnableOption "jellyfin profile";
    libraryDirs = lib.mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = [ "/var/lib/jellyfin/media" ];
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: figure out how to setup these directories
    systemd.tmpfiles.settings."jellyfinDirs" = lib.mkIf (cfg.libraryDirs != [ ]) (
      lib.genAttrs cfg.libraryDirs (_: {
        "d" = {
          user = "media";
          # group = "media";
          mode = "1755";
        };
      })
    );
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
