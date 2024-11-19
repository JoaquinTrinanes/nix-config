{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.desktop;
in
{
  imports = [
    ./gnome.nix
    ./wayland.nix
    ./hyprland.nix
  ];

  options.profiles.desktop = {
    enable = lib.mkEnableOption "desktop profile";
  };

  config = lib.mkIf cfg.enable {
    xdg.mime.enable = lib.mkDefault true;

    profiles.firefox.enable = lib.mkDefault true;
    profiles.desktop.gnome.enable = lib.mkDefault true;
    profiles.fonts.enable = lib.mkDefault true;
    profiles.audio.enable = lib.mkDefault true;
    profiles.autofirma.enable = lib.mkDefault true;

    profiles.desktop.hyprland.enable = true;

    time.timeZone = lib.mkDefault "Europe/Madrid";

    environment.enableAllTerminfo = lib.mkDefault true;

    services.libinput.touchpad = lib.mkDefault {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
    };
    services.xserver = {
      enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;
    };

    environment.systemPackages =
      let
        discord = pkgs.vesktop;
      in
      builtins.attrValues {
        inherit discord;
        inherit (pkgs)
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
  };
}
