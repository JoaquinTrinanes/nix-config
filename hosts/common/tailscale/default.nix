{ lib, ... }:
{
  services.tailscale = {
    enable = lib.mkDefault true;
    # Disallow incoming connections by default, must be overriden with mkForce
    extraUpFlags = [ "--shields-up" ];
  };
}
