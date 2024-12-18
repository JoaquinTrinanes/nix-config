{
  config,
  pkgs,
  lib,
  ...
}:
let
  shellIntegrationStr = ''
    if [[ $TERM_PROGRAM = "WezTerm" ]]; then
      source "${config.programs.wezterm.package}/etc/profile.d/wezterm.sh"
    fi
  '';
in
{
  programs.wezterm = {
    enable = true;
    package = lib.my.mkWrapper {
      basePackage = pkgs.wezterm;
      env = {
        # prevent dGPU not powering off when front_end = "WebGpu"
        VK_ICD_FILENAMES.value = "${pkgs.mesa.drivers}/share/vulkan/icd.d/radeon_icd.x86_64.json";
      };

    };
    colorSchemes."base16" =
      let
        c = config.colorScheme.palette;
      in
      {
        ansi = [
          c.base00
          c.base08
          c.base0B
          c.base0A
          c.base0D
          c.base0E
          c.base0C
          c.base05
        ];
        brights = [
          c.base03
          c.base08
          c.base0B
          c.base0A
          c.base0D
          c.base0E
          c.base0C
          c.base07
        ];
        background = c.base00;
        cursor_bg = c.base05;
        cursor_fg = c.base00;
        compose_cursor = c.base06;
        foreground = c.base05;
        scrollbar_thumb = c.base03;
        selection_bg = c.base05;
        selection_fg = c.base00;
        split = c.base03;
        visual_bell = c.base09;
        tab_bar = {
          background = c.base01;
          inactive_tab_edge = c.base01;
          active_tab = {
            bg_color = c.base03;
            fg_color = c.base05;
          };
          inactive_tab = {
            bg_color = c.base00;
            fg_color = c.base05;
          };
          inactive_tab_hover = {
            bg_color = c.base05;
            fg_color = c.base00;
          };
          new_tab = {
            bg_color = c.base00;
            fg_color = c.base05;
          };
          new_tab_hover = {
            bg_color = c.base05;
            fg_color = c.base00;
          };
        };
      };
    enableBashIntegration = false;
    enableZshIntegration = false;
  };
  xdg.configFile."wezterm/wezterm.lua".source =
    config.lib.impurePath.mkImpureLink ./files/wezterm.lua;

  programs.bash.initExtra = lib.mkAfter shellIntegrationStr;
  programs.zsh.initExtra = lib.mkAfter shellIntegrationStr;

}
