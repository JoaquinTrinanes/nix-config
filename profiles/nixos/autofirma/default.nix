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
  imports = [ inputs.autofirma-nix.nixosModules.autofirma ];

  options.profiles.autofirma = {
    enable = lib.mkEnableOption "autofirma profile";
  };

  config = lib.mkIf cfg.enable {
    programs.autofirma = lib.mkDefault {
      enable = true;
      firefoxIntegration.enable = false;
    };

    programs.firefox.preferences = {
      "network.protocol-handler.app.afirma" = lib.mkDefault (
        lib.getExe config.programs.autofirma.package
      );
      # "network.protocol-handler.warn-external.afirma" = false;
      "network.protocol-handler.external.afirma" = lib.mkDefault true;
    };
  };
}
