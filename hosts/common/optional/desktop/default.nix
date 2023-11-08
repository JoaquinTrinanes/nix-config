{pkgs, ...}: {
  imports = [
    ./gnome.nix
    ../audio.nix
    ../fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    firefox
    discord
    qbittorrent
    telegram-desktop
    # xorg.libxcb.dev
    vlc
  ];
  programs.dconf.enable = true;
  programs.firefox = {
    # enable = true;
    # package = pkgs.firefox-devedition;
    nativeMessagingHosts.packages = with pkgs; [enpass];
  };

  xdg.portal.enable = true;

  services.switcherooControl.enable = true;
}
