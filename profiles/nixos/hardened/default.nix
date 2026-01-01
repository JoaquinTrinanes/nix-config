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
      enable = true;
      execWheelOnly = true;
    };
    boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_hardened;

    security = {
      forcePageTableIsolation = lib.mkDefault true;
      allowSimultaneousMultithreading = lib.mkDefault true;
      unprivilegedUsernsClone = lib.mkDefault config.virtualisation.containers.enable;
      allowUserNamespaces = lib.mkDefault true;

      apparmor = {
        enable = lib.mkDefault true;
        killUnconfinedConfinables = lib.mkDefault true;
      };
    };

  };

}
