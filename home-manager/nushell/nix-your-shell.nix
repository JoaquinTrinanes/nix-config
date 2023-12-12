{
  pkgs,
  config,
  lib,
  ...
}: let
  path = "${config.xdg.cacheHome}/nix-your-shell/nix-your-shell.nu";
in {
  programs.nushell.extraEnv = ''
    mkdir ${builtins.dirOf path}
    ${lib.getExe pkgs.nix-your-shell} "nu" | save -f ${path}
  '';
  programs.nushell.extraConfig = ''
    source ${path}
  '';
}
