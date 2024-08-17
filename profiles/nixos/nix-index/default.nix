{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.profiles.nix-index;
in
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  options.profiles.nix-index = {
    enable = lib.mkEnableOption "nix-index profile";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-index = lib.mkDefault {
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };
    programs.nix-index-database.comma.enable = lib.mkDefault true;
    programs.command-not-found.enable = lib.mkDefault false;
  };
}
