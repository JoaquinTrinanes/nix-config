# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # inputs.hardware.nixosModules.common-gpu-nvidia-disable
    # inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.msi-gl62
  ];

  profiles.hardware-acceleration = {
    enable = true;
    cpuType = "intel";
  };

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  services.tlp = {
    enable = true;
    settings = {
      RUNTIME_PM_ON_AC = "auto";
      USB_AUTOSUSPEND = 0;
      USB_EXCLUDE_BTUSB = 1;
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me";

      # prevents powering down dGPU?
      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };
  services.power-profiles-daemon.enable = false;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = false;
    nvidiaSettings = false;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
  };

  environment.variables = {
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "sd_mod"
    "rtsx_usb_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = lib.mkMerge [
    [
      "ibt=off"
      "module_blacklist=nouveau"
    ]
    (lib.mkIf (!config.hardware.nvidia.modesetting.enable)
      # last entries have priority, and the modeset=1 needs to be overriden
      (lib.mkAfter [ "nvidia-drm.modeset=0" ])
    )
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8d8c71da-0d28-4163-9179-31f3ec811272";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-8cd4a7b7-cfaf-4aa9-b523-23abd20b65b8".device = "/dev/disk/by-uuid/8cd4a7b7-cfaf-4aa9-b523-23abd20b65b8";

  boot.loader.efi.efiSysMountPoint = "/boot";
  fileSystems.${config.boot.loader.efi.efiSysMountPoint} = {
    device = "/dev/disk/by-uuid/5553-7C4C";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/7471f9de-4e2d-4d56-8d13-40cd3d40e4ae"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
