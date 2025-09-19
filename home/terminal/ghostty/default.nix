{
  pkgs,
  config,
  lib,
  ...
}:
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
}
