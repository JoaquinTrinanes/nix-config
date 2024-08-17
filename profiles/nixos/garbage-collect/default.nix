{ lib, config, ... }:
let
  cfg = config.profiles.garbage-collect;
in
{
  options.profiles.garbage-collect = {
    enable = lib.mkEnableOption "garbage-collect profile";
  };

  config = lib.mkIf cfg.enable {
    nix.gc = lib.mkDefault {
      automatic = true;
      persistent = true;
      dates = "weekly";
    };
  };
}
