{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}) ghostty;
in
{
  home.packages = [ ghostty ];
  xdg.configFile."ghostty/config".source = config.lib.impurePath.mkImpureLink ./config;
}
