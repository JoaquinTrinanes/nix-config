{pkgs, ...}: {
  imports = [
    ./gnome.nix
    ../audio.nix
    ../fonts.nix
    ../printing.nix
  ];

  environment.systemPackages = with pkgs; [
    firefox
    discord
    qbittorrent
    telegram-desktop
    vlc
  ];
  programs.dconf.enable = true;
  programs.firefox = {
    nativeMessagingHosts.packages = with pkgs; [enpass];
  };

  xdg.portal.enable = true;
}
