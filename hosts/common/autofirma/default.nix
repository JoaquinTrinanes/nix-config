{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.autofirma-nix.nixosModules.autofirma ];
  programs.autofirma = {
    enable = true;
    firefoxIntegration.enable = false;
  };

  programs.firefox.preferences = {
    "network.protocol-handler.app.afirma" = lib.getExe config.programs.autofirma.package;
    # "network.protocol-handler.warn-external.afirma" = false;
    "network.protocol-handler.external.afirma" = true;
  };
}
