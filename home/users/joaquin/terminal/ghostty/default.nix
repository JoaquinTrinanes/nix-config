{
  pkgs,
  config,
  inputs,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.ghostty;
    settings = {
      theme = config.colorScheme.slug;
      config-file = "${config.lib.impurePath.mkImpureLink ./config}";
      auto-update = "off";
    };
  };
}
