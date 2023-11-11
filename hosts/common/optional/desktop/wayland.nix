{pkgs, ...}: {
  services.xserver.displayManager.gdm.wayland = true;

  environment.systemPackages = with pkgs; [
    # bridge dep?
    xorg.libxcb.dev
    wl-clipboard
    xwaylandvideobridge
  ];

  xdg = {
    portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
      ];
    };
  };
}
