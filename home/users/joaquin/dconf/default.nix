{
  lib,
  pkgs,
  ...
}: let
  extensions = builtins.attrValues {
    inherit
      (pkgs.gnomeExtensions)
      dash-to-panel
      espresso
      appindicator
      night-theme-switcher
      user-themes
      blur-my-shell
      ;
  };
  inherit (lib.hm.gvariant) mkTuple;
in {
  xdg.dataFile =
    lib.listToAttrs (map (e: lib.nameValuePair "gnome-shell/extensions/${e.extensionUuid}" {source = "${e}/share/gnome-shell/extensions/${e.extensionUuid}";})
      extensions);

  home.packages =
    builtins.attrValues {
      inherit (pkgs.gnome) gnome-tweaks;
      inherit (pkgs) paper-icon-theme;
    }
    ++ [(lib.mkIf config.gtk.enable config.gtk.theme.package)]
    ++ extensions;
  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = false;
    };
    "org/gnome/shell" = {
      favorite-apps = ["org.gnome.Nautilus.desktop" "firefox-devedition.desktop" "discord.desktop" "org.wezfurlong.wezterm.desktop"];
      disable-user-extensions = false;
      enabled-extensions =
        builtins.map
        (extension: extension.extensionUuid)
        extensions;
    };
    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      text-scaling-factor = 1.25;
      show-battery-percentage = true;
      enable-hot-corners = false;
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/shell/extensions/espresso" = {
      show-notifications = false;
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
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
      switch-applications = ["<Super>Tab"];
      switch-applications-backward = ["<Shift><Super>Tab"];
    };
    "org/gnome/desktop/input-sources" = {
      show-all-sources = true;
      sources = [(mkTuple ["xkb" "us"]) (mkTuple ["xkb" "es"])];
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
