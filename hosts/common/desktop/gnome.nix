{ pkgs, inputs, ... }:
{
  imports = [ ./wayland.nix ];

  services.xserver = {
    desktopManager.gnome.enable = true;
    desktopManager.gnome.sessionPath = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dynamic-gnome-wallpapers
    ];
  };
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.gnome.excludePackages =
    builtins.attrValues {
      inherit (pkgs)
        gnome-connections
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
        gnome-font-viewer
        ;
    }
    ++ (with pkgs.gnome; [
      gnome-contacts
      gnome-logs
      # gnome-calculator
      # gnome-calendar
      # gnome-characters
      # gnome-clocks
      # gnome-disk-utility
      gnome-maps
      gnome-music
      # gnome-photos
      # gnome-screenshot
      # gnome-system-monitor
      gnome-weather

    ]);

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) pinentry-gnome3 gnome-tweaks adwaita-icon-theme;
  };

  # TODO: see if this works after reboot (ensure .config/mimeapps.list doesn't exist)
  xdg.mime.defaultApplications = {
    "text/plain" = "gnome-text-editor.desktop";
  };
}
