{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # bridge dep?
    xorg.libxcb.dev
    wl-clipboard
    xwaylandvideobridge
  ];
}
