{ lib, config, ... }:
let
  cfg = config.profiles.tailscale;
in
{
  options.profiles.tailscale = {
    enable = lib.mkEnableOption "tailscale profile";
    shieldsUp = lib.mkEnableOption "tailscale shields up" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = lib.mkDefault true;
      extraUpFlags = lib.optionals cfg.shieldsUp [ "--shields-up" ];
    };
  };
}
