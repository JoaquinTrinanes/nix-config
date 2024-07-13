{ pkgs, ... }:
{
  services.xserver.displayManager.gdm.wayland = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    # # Doesn't work
    # xwaylandvideobridge
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.portal.wlr.enable = true;
}
