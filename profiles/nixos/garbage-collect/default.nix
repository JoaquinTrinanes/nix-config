{ lib, config, ... }:
let
  cfg = config.profiles.garbageCollect;
in
{
  options.profiles.garbageCollect = {
    enable = lib.mkEnableOption "garbage collect profile";
  };

  config = lib.mkIf cfg.enable {
    nix.gc = lib.mkDefault {
      automatic = true;
      persistent = true;
      dates = "weekly";
    };
  };
}
