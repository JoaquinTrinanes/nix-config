{
  self,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.programs.autofirma;
  autofirma = self.packages.${pkgs.stdenv.hostPlatform.system}.autofirma.override {
    firefox = config.programs.firefox.package;
  };
in {
  options.programs.autofirma = {
    enable = lib.mkEnableOption "autofirma";
    package = lib.mkOption {
      default = autofirma;
      type = lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    programs.firefox.preferences = {
      "network.protocol-handler.app.afirma" = lib.getExe cfg.package;
      # "network.protocol-handler.warn-external.afirma" = false;
      "network.protocol-handler.external.afirma" = true;
    };
  };
}
