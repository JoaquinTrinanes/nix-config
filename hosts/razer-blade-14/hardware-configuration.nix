{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    ../common/optional/hardware-acceleration/amdgpu.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.supportedFilesystems = ["ntfs"];
  boot.extraModulePackages = [];
  boot.kernelParams = [
    "acpi_backlight=native" # fixes brightness control
  ];
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      # device = "/dev/disks/by-uuid/bb1eca97-4a4a-4f27-8f73-2facd71f55ff";
      device = "/dev/mapper/vg-cryptroot";
      preLVM = false;
    };
  };

  boot.loader.efi.efiSysMountPoint = "/efi";

  fileSystems."/efi" = {
    device = "/dev/nvme0n1p1";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p7";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    # device = "/dev/disk/by-uuid/bb1eca97-4a4a-4f27-8f73-2facd71f55ff";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
      randomEncryption.enable = true;
    }
  ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "prime-run" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  # networking.interfaces."enp101s0f3u1".useDHCP = true;
  # networking.interfaces."wlp2s0".useDHCP = true;

  services.tlp.enable = true;
  services.tlp.settings = {
    # TLP_ENABLE = 0;
    RUNTIME_PM_ON_AC = "auto";
    USB_AUTOSUSPEND = 0;
    USB_EXCLUDE_BTUSB = 1;
  };
  services.power-profiles-daemon.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.nvidia = {
    modesetting.enable = false;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:64:00:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
