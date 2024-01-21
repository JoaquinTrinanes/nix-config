{
  self,
  pkgs,
  config,
  lib,
  ...
}: let
  autofirma = self.packages.${pkgs.stdenv.hostPlatform.system}.autofirma.override {firefox = config.programs.firefox.package;};
in {
  environment.systemPackages = [autofirma];

  programs.firefox.preferences = {
    "network.protocol-handler.app.afirma" = lib.getExe autofirma;
    # "network.protocol-handler.warn-external.afirma" = false;
    "network.protocol-handler.external.afirma" = true;
  };
}
