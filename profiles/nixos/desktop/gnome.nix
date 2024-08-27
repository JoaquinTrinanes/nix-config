{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  desktopCfg = config.profiles.desktop;
  cfg = desktopCfg.gnome;
in
{
  imports = [ ./wayland.nix ];

  options.profiles.desktop.gnome = {
    enable = lib.mkEnableOption "gnome desktop profile";
  };

  config = lib.mkIf cfg.enable (
    lib.mkDefault {
      services.xserver = {
        desktopManager.gnome.enable = true;
        desktopManager.gnome.sessionPath = [
          inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dynamic-gnome-wallpapers
        ];
      };
      programs.dconf.enable = true;
      services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

      environment.gnome.excludePackages = builtins.attrValues {
        inherit (pkgs)
          gnome-connections
          gnome-contacts
          gnome-tour
          # baobab # disk usage analyzer
          # cheese # photo booth
          # eog # image viewer
          # gedit # text editor
          totem # video player
          yelp # help viewer
          # evince # document viewer
          # file-roller # archive manager
          geary # email client
          # seahorse # password manager
          # gnome-font-viewer
          gnome-logs
          gnome-maps
          gnome-music
          gnome-weather

          # gnome-calculator
          # gnome-calendar
          # gnome-characters
          # gnome-clocks
          # gnome-disk-utility
          # gnome-photos
          # gnome-screenshot
          # gnome-system-monitor
          ;
      };

      environment.systemPackages = builtins.attrValues {
        inherit (pkgs) pinentry-gnome3 gnome-tweaks adwaita-icon-theme;
      };

      # TODO: see if this works after reboot (ensure .config/mimeapps.list doesn't exist)
      xdg.mime.defaultApplications = {
        "text/plain" = "gnome-text-editor.desktop";
      };
    }
  );
}
