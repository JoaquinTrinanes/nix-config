{ pkgs, ... }:
{
  imports = [
    ./ghostty
    ./kitty
    ./wezterm
  ];

  home.packages = [ pkgs.xdg-terminal-exec ];

  xdg.configFile."xdg-terminals.list".text = ''
    com.mitchellh.ghostty.desktop
    org.wezfurlong.wezterm.desktop
    kitty.desktop
  '';
}
