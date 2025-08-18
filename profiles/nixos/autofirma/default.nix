{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.autofirma;
in
{
  imports = [ inputs.autofirma-nix.nixosModules.default ];

  options.profiles.autofirma = {
    enable = lib.mkEnableOption "autofirma profile";
  };

  config = lib.mkIf cfg.enable {
    programs.autofirma = lib.mkDefault {
      enable = true;
      firefoxIntegration.enable = true;
    };
    programs.configuradorfnmt = {
      enable = true;
      firefoxIntegration.enable = true;
    };
  };
}
