{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = lib.mapAttrs (_: color: "#${color}") config.colorScheme.palette;
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
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 16;
    };
    keybindings = {
      "ctrl+alt+-" = "launch --location=hsplit --cwd=current";
      "ctrl+alt+\\" = "launch --location=vsplit --cwd=current";
      "ctrl+alt+|" = "launch --location=vsplit --cwd=current";
      # "ctrl+shift+l" = "kitty_shell window";
      "ctrl+shift+escape" = "kitty_shell window";
    };
    settings = lib.mkMerge [
      {
        disable_ligatures = "cursor";
        enable_audio_bell = false;
        touch_scroll_multiplier = 5;
        allow_remote_control = true;
        listen_on = if pkgs.stdenv.isLinux then "unix:@mykitty" else "/tmp/mykitty";
        enabled_layouts = lib.concatStringsSep "," [
          "splits"
          "all"
        ];
      }
      theme
    ];
    extraConfig = ''
      map ctrl+j neighboring_window down
      map ctrl+k neighboring_window up
      map ctrl+h neighboring_window left
      map ctrl+l neighboring_window right

      # Unset the mapping to pass the keys to neovim
      map --when-focus-on var:IS_NVIM ctrl+j
      map --when-focus-on var:IS_NVIM ctrl+k
      map --when-focus-on var:IS_NVIM ctrl+h
      map --when-focus-on var:IS_NVIM ctrl+l

      # the 3 here is the resize amount, adjust as needed
      map alt+j kitten relative_resize.py down  3
      map alt+k kitten relative_resize.py up    3
      map alt+h kitten relative_resize.py left  3
      map alt+l kitten relative_resize.py right 3

      map --when-focus-on var:IS_NVIM alt+j
      map --when-focus-on var:IS_NVIM alt+k
      map --when-focus-on var:IS_NVIM alt+h
      map --when-focus-on var:IS_NVIM alt+l
    '';
  };
  # xdg.configFile."kitty/pass_keys.py".source = "${smart-splits-nvim}/kitty/pass_keys.py";
  xdg.configFile."kitty/relative_resize.py".source = "${smart-splits-nvim}/kitty/relative_resize.py";
  xdg.configFile."kitty/neighboring_window.py".source = "${smart-splits-nvim}/kitty/neighboring_window.py";
}
