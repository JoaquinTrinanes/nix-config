{ pkgs, lib, ... }:
{
  imports = [
    ./ghostty
    ./kitty
    ./wezterm
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs) nautilus-open-any-terminal xdg-terminal-exec;
  };

  xdg.configFile."xdg-terminals.list".text = lib.concatLines [
    "com.mitchellh.ghostty.desktop"
    "org.wezfurlong.wezterm.desktop"
    "kitty.desktop"
  ];

  dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal" = {
    terminal = "custom"; # lib.head terminalPriorities;
    new-tab = true;
    custom-local-command = "xdg-terminal-exec --dir=%s";
  };
}
