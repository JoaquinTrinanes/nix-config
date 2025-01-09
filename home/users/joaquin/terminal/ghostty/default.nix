{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home.packages = [
    # pkgs.ghostty
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.ghostty
  ];
  xdg.configFile."ghostty/config".text = ''
    theme = ${config.colorScheme.slug}
    config-file = ${config.lib.impurePath.mkImpureLink ./config}
  '';
}
