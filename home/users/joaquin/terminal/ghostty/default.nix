{
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}) ghostty;
in
{
  programs.ghostty = {
    enable = true;
    package = pkgs.my.mkWrapper {
      basePackage = ghostty;
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
