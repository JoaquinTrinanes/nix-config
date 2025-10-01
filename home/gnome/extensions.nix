{ pkgs, ... }:
let
  extensions = builtins.attrValues {
    inherit (pkgs.gnomeExtensions)
      appindicator
      blur-my-shell
      caffeine
      color-picker
      dash-to-panel
      night-theme-switcher
      user-themes
      ;
  };
in
{
  programs.gnome-shell = {
    enable = true;
    extensions = map (ext: { package = ext; }) extensions;
  };
}
