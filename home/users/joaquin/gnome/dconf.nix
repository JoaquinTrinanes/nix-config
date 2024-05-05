{ lib, ... }:
let
  inherit (lib.hm.gvariant) mkTuple;
in
{
  dconf.settings = {
    # "org/gnome/shell/extensions/user-theme" = {
    #   inherit (config.gtk.theme) name;
    #   # gtk-theme = name;
    # };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = false;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox-devedition.desktop"
        "discord.desktop"
        "org.wezfurlong.wezterm.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      icon-theme = "Adwaita";
      clock-show-weekday = true;
      clock-format = "24h";
      text-scaling-factor = 1.25;
      show-battery-percentage = true;
      enable-hot-corners = false;
      # gtk-theme = config.gtk.theme.name;
    };
    "org/gnome/TextEditor" = {
      custom-font = "FiraCode Nerd Font 12";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      # experimental-features = [ "scale-monitor-framebuffer" ];
      experimental-features = [ ];
    };
    "org/gnome/shell/extensions/espresso" = {
      show-notifications = false;
    };
    "org/gnome/shell/extensions/nightthemeswitcher/time" = {
      location = mkTuple [
        42.87672
        (-8.547082)
      ];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/nautilus/preferences" = {
      # Editable address bar
      always-use-location-entry = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "wezterm";
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
