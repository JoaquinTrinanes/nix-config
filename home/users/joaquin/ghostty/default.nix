{
  pkgs,
  config,
  ...
}:
{
  home.packages = [ pkgs.ghostty ];
  xdg.configFile."ghostty/config".text = ''
    theme = ${config.colorScheme.slug}
    config-file = ${config.lib.impurePath.mkImpureLink ./config}
  '';
}
