{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./direnv.nix];
  programs.nushell = {
    enable = lib.mkDefault true;
    package = pkgs.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./config/config.nu;
    envFile.source = ./config/env.nu;
    extraConfig = ''
      overlay use ${./config/scripts/aliases}
      overlay use ${./config/scripts/completions}
    '';
  };
  programs.carapace.enable = true;
  xdg.configFile."nushell/scripts" = {
    source = ../../modules/nushell/config/scripts; # config.lib.file.mkOutOfStoreSymlink ./config/nushell;
    recursive = true;
  };
}
