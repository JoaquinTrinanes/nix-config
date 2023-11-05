{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./direnv.nix ./theme.nix];
  programs.nushell = {
    enable = lib.mkDefault true;
    package = pkgs.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./files/config.nu;
    envFile.source = ./files/env.nu;
    extraConfig = ''
      overlay use ${./files/scripts/aliases}
      overlay use ${./files/scripts/completions}
    '';
  };
  programs.carapace.enable = true;
  xdg.configFile."nushell/scripts" = {
    source = ./files/scripts; # config.lib.file.mkOutOfStoreSymlink ./config/nushell;
    recursive = true;
  };
}
