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
    };
  };
}
