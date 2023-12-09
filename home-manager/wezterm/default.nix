{
  config,
  lib,
  pkgs,
  myLib,
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./files/wezterm.lua;
    colorSchemes."nix-colors" = with config.colorScheme.colors; {
      ansi = [base00 base08 base0B base0A base0D base0E base0C base05];
      brights = [base03 base08 base0B base0A base0D base0E base0C base07];
      background = base00;
      cursor_bg = base05;
      cursor_fg = base00;
      compose_cursor = base06;
      foreground = base05;
      scrollbar_thumb = base01;
      selection_bg = base05;
      selection_fg = base00;
      split = base03;
      visual_bell = base09;
      tab_bar = {
        background = base01;
        inactive_tab_edge = base01;
        active_tab = {
          bg_color = base03;
          fg_color = base05;
        };
        inactive_tab = {
          bg_color = base00;
          fg_color = base05;
        };
        inactive_tab_hover = {
          bg_color = base05;
          fg_color = base00;
        };
        new_tab = {
          bg_color = base00;
          fg_color = base05;
        };
        new_tab_hover = {
          bg_color = base05;
          fg_color = base00;
        };
      };
    };
  };
  xdg.configFile."wezterm/wezterm.lua" = {
    source = myLib.mkImpureLink ./files/wezterm.lua;
    recursive = true;
  };
}
