{ lib, ... }:
{
  nix.gc = {
    automatic = lib.mkDefault true;
    persistent = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
  };
}
