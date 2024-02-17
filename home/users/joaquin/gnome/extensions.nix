{
  pkgs,
  lib,
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
      color-picker
      ;
  };
in {
  xdg.dataFile =
    lib.listToAttrs (map (e: lib.nameValuePair "gnome-shell/extensions/${e.extensionUuid}" {source = "${e}/share/gnome-shell/extensions/${e.extensionUuid}";})
      extensions);
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions =
        builtins.map
        (extension: extension.extensionUuid)
        extensions;
    };
  };
}
