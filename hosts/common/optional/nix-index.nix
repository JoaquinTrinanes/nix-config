{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nix-index-database.nixosModules.nix-index];
  programs.nix-index = {
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };
  programs.nix-index-database.comma.enable = lib.mkDefault true;
  programs.command-not-found.enable = lib.mkDefault false;
}
