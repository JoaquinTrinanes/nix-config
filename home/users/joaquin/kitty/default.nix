{
  config,
  lib,
  pkgs,
  ...
}: let
  colors = lib.mapAttrs (_: color: "#${color}") config.colorScheme.colors;
  theme = with colors; {
    background = base00;
    foreground = base05;
    selection_background = base05;
    selection_foreground = base00;
    url_color = base04;
    cursor = base05;
    active_border_color = base03;
    inactive_border_color = base01;
    active_tab_background = base00;
    active_tab_foreground = base05;
    inactive_tab_background = base01;
    inactive_tab_foreground = base04;
    tab_bar_background = base01;

    # normal
    color0 = base00;
    color1 = base08;
    color2 = base0B;
    color3 = base0A;
    color4 = base0D;
    color5 = base0E;
    color6 = base0C;
    color7 = base05;

    # bright
    color8 = base03;
    color9 = base08;
    color10 = base0B;
    color11 = base0A;
    color12 = base0D;
    color13 = base0E;
    color14 = base0C;
    color15 = base07;

    # extended base16 colors
    color16 = base09;
    color17 = base0F;
    color18 = base01;
    color19 = base02;
    color20 = base04;
    color21 = base06;
  };
  inherit (pkgs.vimPlugins) smart-splits-nvim;
in {
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 16;
    };
    keybindings = {
      "ctrl+j" = "kitten pass_keys.py neighboring_window bottom ctrl+j";
      "ctrl+k" = "kitten pass_keys.py neighboring_window top    ctrl+k";
      "ctrl+h" = "kitten pass_keys.py neighboring_window left   ctrl+h";
      "ctrl+l" = "kitten pass_keys.py neighboring_window right  ctrl+l";

      # the 3 here is the resize amount, adjust as needed
      "alt+j" = "kitten pass_keys.py relative_resize down  3 alt+j";
      "alt+k" = "kitten pass_keys.py relative_resize up    3 alt+k";
      "alt+h" = "kitten pass_keys.py relative_resize left  3 alt+h";
      "alt+l" = "kitten pass_keys.py relative_resize right 3 alt+l";

      "ctrl+alt+-" = "launch --location=hsplit";
      "ctrl+alt+\\" = "launch --location=vsplit";
    };
    settings =
      {
        bold_font = "FiraCode Nerd Font SemBd";
        bold_italic_font = "FiraCode Nerd Font SemBd";
        disable_ligatures = "cursor";
        enable_audio_bell = false;
      }
      // theme;
  };
  xdg.configFile."kitty/pass_keys.py".source = "${smart-splits-nvim}/kitty/pass_keys.py";
  xdg.configFile."kitty/relative_resize.py".source = "${smart-splits-nvim}/kitty/relative_resize.py";
  xdg.configFile."kitty/neighboring_window.py".source = "${smart-splits-nvim}/kitty/neighboring_window.py";
}
