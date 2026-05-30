{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      flatpak
      gnome-software
      ;
  };

  xdg.systemDirs.data = [
    "$HOME/.local/share/flatpak/exports/share"
  ];
  home.sessionPath = [
    "$HOME/.local/share/flatpak/exports/bin"
  ];

}
