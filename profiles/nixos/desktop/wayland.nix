{
  pkgs,
  lib,
  config,
  ...
}:
let
  desktopCfg = config.profiles.desktop;
  cfg = desktopCfg.wayland;
in
{
  options.profiles.desktop.wayland = {
    enable = lib.mkEnableOption "wayland desktop profile" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.wayland.enable = lib.mkDefault true;
    services.xserver.displayManager.gdm.wayland = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      # # Doesn't work
      # xwaylandvideobridge
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = lib.mkDefault "1";
      ELECTRON_OZONE_PLATFORM_HINT = lib.mkDefault "auto";
    };

    xdg.portal.wlr.enable = lib.mkDefault true;
  };
}
