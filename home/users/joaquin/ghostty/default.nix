{
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}) ghostty;
in
{
  home.packages = [ ghostty ];
  xdg.configFile."ghostty/config".text = ''
    theme = ${config.colorScheme.slug}
    config-file = ${config.lib.impurePath.mkImpureLink ./config}
  '';
}
