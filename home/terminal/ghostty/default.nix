{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.ghostty;
in
{
  programs.ghostty = {
    enable = true;
    package = pkgs.my.mkWrapper {
      basePackage = pkgs.ghostty;
      postBuild = ''
        rm -rf $out/share/nautilus-python
      '';
    };
    settings = {
      theme = lib.mkIf (config.colors.name != null) config.colors.name;
      config-file = "${config.lib.impurePath.mkImpureLink ./config}";
      auto-update = "off";
    };
  };
  xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service" = {
    enable =
      config.programs.ghostty.enable
      && (lib.head config.xdg.terminal-exec.settings.default) == "com.mitchellh.ghostty.desktop";
    source = "${cfg.package}/share/systemd/user/app-com.mitchellh.ghostty.service";
  };
}
