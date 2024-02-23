{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./gnome.nix
    ../audio
    ../fonts
    ../firefox
    ../autofirma
  ];

  time.timeZone = lib.mkDefault "Europe/Madrid";

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      discord
      ferdium
      qbittorrent
      telegram-desktop
      vlc
      ;
  };
  programs.dconf.enable = true;

  nix.daemonCPUSchedPolicy = "idle";

  xdg.portal.enable = true;
}
