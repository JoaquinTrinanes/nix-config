{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.hardened;
in
{
  options.profiles.hardened = {
    enable = lib.mkEnableOption "hardened profile" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo-rs = {
      enable = lib.mkDefault true;
      execWheelOnly = lib.mkDefault true;
    };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    security = {
      forcePageTableIsolation = lib.mkDefault true;
      allowSimultaneousMultithreading = lib.mkDefault true;
      allowUserNamespaces = lib.mkDefault true;

      apparmor = {
        enable = lib.mkDefault true;
        killUnconfinedConfinables = lib.mkDefault true;
      };
    };

  };

}
