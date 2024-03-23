{ pkgs, lib, ... }:
{
  imports = [
    ./gnome.nix
    ../audio
    ../fonts
    ../firefox
    ../autofirma
  ];

  time.timeZone = lib.mkDefault "Europe/Madrid";

  environment.enableAllTerminfo = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    libinput.touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      discord
      ferdium
      protonvpn-gui
      qbittorrent
      telegram-desktop
      vlc
      ;
  };
  programs.dconf.enable = lib.mkDefault true;
  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          # two-finger-scrolling-enabled = true;
          # natural-scroll = false;
        };
      };
    }
  ];

  nix.daemonCPUSchedPolicy = lib.mkDefault "idle";

  xdg.portal.enable = lib.mkDefault true;
}
