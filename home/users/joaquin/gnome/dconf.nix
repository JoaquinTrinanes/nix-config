{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.gvariant) mkTuple;
in
{
  imports = [
    {
      dconf.settings =
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dynamic-gnome-wallpapers.Rancho.dconfSettings;
    }
  ];

  dconf.settings = {
    # "org/gnome/shell/extensions/user-theme" = {
    #   inherit (config.gtk.theme) name;
    #   # gtk-theme = name;
    # };
    "org/gnome/Console" = {
      audible-bell = false;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = false;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = true;
    };
    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
    "org/gnome/shell" = {
      favorite-apps =
        let
          getDesktopItem =
            pkg:
            pkg.desktopItem
              or (if ((lib.length (pkg.desktopItems or [ ])) != 0) then lib.head pkg.desktopItems else null);
          getName = pkg: (getDesktopItem pkg).name;
        in
        [ "org.gnome.Nautilus.desktop" ]
        ++ [ (getName inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.firefox) ]
        ++ [
          (getName pkgs.vesktop)
          "com.mitchellh.ghostty.desktop"
          (getName pkgs.vesktop)
          "com.mitchellh.ghostty.desktop"
        ];
    };
    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      clock-format = "24h";
      text-scaling-factor = lib.mkDefault 1.25;
      show-battery-percentage = true;
      enable-hot-corners = false;

      # Remove invalid values if theme changes
      cursor-theme = lib.mkDefault (lib.hm.gvariant.mkNothing "s");
      icon-theme = lib.mkDefault (lib.hm.gvariant.mkNothing "s");
      gtk-theme = lib.mkDefault (lib.hm.gvariant.mkNothing "s");
      cursor-size = lib.mkDefault (lib.hm.gvariant.mkNothing "s");
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell/extensions/caffeine" = {
      show-notifications = false;
    };
    "org/gnome/shell/extensions/nightthemeswitcher/time" = {
      location = mkTuple [
        42.87672
        (-8.547082)
      ];
    };
    "org/gnome/shell/extensions/appindicator" = {
      legacy-tray-enabled = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/nautilus/preferences" = {
      # Editable address bar
      # Only when the setting is false can both forms of location navigation be employed.
      always-use-location-entry = false;
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "xdg-terminal-exec";
      name = "Launch terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
        (mkTuple [
          "xkb"
          "es"
        ])
      ];
    };
    "org/gnome/shell/extensions/dash-to-panel" = {
      hide-overview-on-startup = true;
      overview-click-to-exit = true;
      trans-use-custom-opacity = true;
      trans-panel-opacity = 0.2;
    };
    # "org/gnome/desktop/datetime" = {
    #   automatic-timezone = true;
    # };
    # "org/gnome/system/location" = {
    #   enabled = true;
    # };
  };
}
