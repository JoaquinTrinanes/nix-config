{
  pkgs,
  lib,
  config,
  ...
}:
let
  desktopCfg = config.profiles.desktop;
  cfg = desktopCfg.hyprland;
in
{
  options.profiles.desktop.hyprland = {
    enable = lib.mkEnableOption "hyprland desktop profile";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = lib.mkDefault true;
    profiles.desktop.wayland.enable = lib.mkDefault true;

    # programs.uwsm = {
    #   enable = true;
    #   waylandCompositors.hyprland = {
    #     binPath = lib.getExe config.programs.hyprland.package; # "/run/current-system/sw/bin/Hyprland";
    #     comment = "Hyprland session managed by uwsm";
    #     prettyName = "Hyprland";
    #   };
    # };

    environment.systemPackages = with pkgs; [
      kitty
      wofi
    ];

    environment.sessionVariables = { };
  };
}
