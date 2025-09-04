{ pkgs, ... }:
{
  imports = [
    ./ghostty
    ./kitty
    ./wezterm
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs) nautilus-open-any-terminal;
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "com.mitchellh.ghostty.desktop"
        "org.wezfurlong.wezterm.desktop"
        "kitty.desktop"
      ];
    };
  };

  dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal" = {
    terminal = "custom";
    new-tab = true;
    custom-local-command = "xdg-terminal-exec --dir=%s";
  };
}
