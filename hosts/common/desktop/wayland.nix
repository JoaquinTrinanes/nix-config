{ pkgs, ... }:
{
  services.xserver.displayManager.gdm.wayland = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xwaylandvideobridge
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg = {
    portal = {
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
    };
  };
}
