{pkgs, ...}: {
  imports = [
    ./gnome.nix
    ./stylix.nix
    ../audio.nix
    ../fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    firefox
    discord
    # xorg.libxcb.dev
  ];
  programs.dconf.enable = true;
  programs.firefox = {
    # enable = true;
    nativeMessagingHosts.packages = with pkgs; [enpass];
  };

  xdg.portal.enable = true;

  services.switcherooControl.enable = true;
}
