{ lib, config, ... }:
let
  cfg = config.profiles.jellyfin;
in
{

  options.profiles.jellyfin = {
    enable = lib.mkEnableOption "jellyfin profile";
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d /mnt/media/Public/jellyfin 1755 media - - -" ];
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
