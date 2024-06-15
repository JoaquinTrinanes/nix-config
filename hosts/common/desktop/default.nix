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

  services.libinput.touchpad = {
    tapping = true;
    scrollMethod = "twofinger";
    naturalScrolling = true;
  };
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
  };

  environment.systemPackages =
    let
      discord = pkgs.vesktop;
    in
    builtins.attrValues {
      inherit discord;
      inherit (pkgs)
        # discord
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
