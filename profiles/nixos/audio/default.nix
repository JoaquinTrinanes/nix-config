{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.audio;
in
{
  options.profiles.audio = {
    enable = lib.mkEnableOption "audio profile";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio = {
      enable = false;
      package = pkgs.pulseaudioFull;
    };
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      # jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
    environment.systemPackages = with pkgs; [ pavucontrol ];
  };
}
