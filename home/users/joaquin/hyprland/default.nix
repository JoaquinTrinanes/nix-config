{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  toHyprconf =
    attrs:
    lib.hm.generators.toHyprconf {
      inherit attrs;
      importantPrefixes = [
        "$"
        "source"
        "preload"
      ];
    };
in
{
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault true;
    plugins = builtins.attrValues { inherit (pkgs.hyprlandPlugins) hyprscroller; };
    settings = {
      source = [ (toString (config.lib.impurePath.mkImpureLink ./hyprland.conf)) ];
    };
    # extraConfig = ''
    #   source = ${config.lib.impurePath.mkImpureLink ./hyprland.conf}
    # '';
  };

  # wayland.windowManager.hyprland.systemd.enable = false;
  programs.waybar = {
    enable = lib.mkDefault true;
    settings = {
      mainBar = {
        layer = "top";
        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/submap"
          # "sway/scratchpad"
          "custom/media"
        ];
        modules-center = [
          "hyprland/window"
        ];
        "modules-right" = [
          "mpd"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "keyboard-state"
          "hyprland/language"
          "battery"
          # "battery#bat2"
          "clock"
          "tray"
          "custom/power"
        ];
        "hyprland/workspaces" = {
          "format" = "{icon}";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
        };
        "hyprland/window" = {
          "separate-outputs" = true;
        };
      };
    };
  };
  xdg.configFile."hypr/hyprpaper.conf".text =
    let
      wp =
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.dynamic-gnome-wallpapers.Rancho.dconfSettings."org/gnome/desktop/background";
      wallpapers = [
        wp.picture-uri
        wp.picture-uri-dark
      ];
    in
    toHyprconf {
      preload = wallpapers;
      wallpaper = ", ${wp.picture-uri}";
    };
  home.packages = builtins.attrValues { inherit (pkgs) hyprpaper rofi; };
  # services.hyprpaper = {
  #   enable = lib.mkDefault true;
  # };
}
