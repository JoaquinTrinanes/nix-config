{ pkgs, ... }:
{
  imports = [
    ./dconf.nix
  ];

  programs.gnome-shell = {
    enable = true;
    extensions =
      let
        extensions = builtins.attrValues {
          inherit (pkgs.gnomeExtensions)
            appindicator
            blur-my-shell
            caffeine
            color-picker
            dash-to-panel
            do-not-disturb-while-screen-sharing-or-recording
            night-theme-switcher
            user-themes
            ;
        };
      in
      map (ext: { package = ext; }) extensions;
  };

}
