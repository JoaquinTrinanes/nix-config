{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.hardware.nixosModules.framework-16-7040-amd
  ];

  services.fwupd.enable = true;

  hardware.amdgpu.opencl.enable = true;

  boot.initrd.systemd.enable = true;

  environment.systemPackages = builtins.attrValues { inherit (pkgs.nvtopPackages) amd; };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.timeout = lib.mkDefault 0;
  boot.supportedFilesystems = {
    ntfs = true;
    btrfs = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = lib.mkDefault true;

  systemd.sleep.extraConfig = ''
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=30m
  '';

  powerManagement = {
    enable = true;
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
