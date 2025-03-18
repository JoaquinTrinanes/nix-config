{ lib, config, ... }:
let
  cfg = config.profiles.printing;
in
{
  options.profiles.printing = {
    enable = lib.mkEnableOption "printing profile";
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = lib.mkDefault true;
      browsing = lib.mkDefault true;
      browsed.enable = lib.mkDefault true;
      startWhenNeeded = lib.mkDefault true;
      stateless = lib.mkDefault true;
      browsedConf = ''
        CreateIPPPrinterQueues All
        UseCUPSGeneratedPPDs Yes
      '';
    };
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = lib.mkDefault true;
    };
  };
}
