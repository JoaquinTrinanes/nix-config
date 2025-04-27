{
  pkgs,
  config,
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
      theme = config.colorScheme.slug;
      config-file = "${config.lib.impurePath.mkImpureLink ./config}";
      auto-update = "off";
    };
  };
}
