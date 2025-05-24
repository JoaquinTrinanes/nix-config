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

    time.timeZone = lib.mkDefault "Europe/Madrid";

    services.libinput.touchpad = lib.mkDefault {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
    };
    services.xserver = {
      enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;
    };

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        vesktop
        discord-canary
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
          };
          "org/gnome/login-screen" = {
            logo = "";
          };
        };
      }
    ];

    nix.daemonCPUSchedPolicy = lib.mkDefault "idle";

    xdg.portal.enable = lib.mkDefault true;
  };
}
