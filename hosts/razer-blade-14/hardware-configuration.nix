{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    ../common/hardware-acceleration/amdgpu.nix
    {
      boot.resumeDevice = "/dev/mapper/root";
      boot.kernelParams = [ "resume_offset=13078528" ];
      systemd.tmpfiles.rules = [
        # Writing 0 causes the size of hibernation images to be minimum
        "w /sys/power/image_size - - - - 0"
      ];
    }
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."root" = {
    # device = "/dev/disk/by-uuid/8c6ae37c-84b9-4d71-be13-b6b384097a5f";
    device = "/dev/mapper/vg-cryptroot";
    preLVM = false;
  };

  boot.loader.efi.efiSysMountPoint = "/efi";

  fileSystems.${config.boot.loader.efi.efiSysMountPoint} = {
    device = "/dev/disk/by-label/ESP";
    # device = "/dev/disk/by-uuid/984F-0AE3";
    # device = "/dev/nvme0n1p3";
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
  networking.useDHCP = lib.mkDefault true;
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

  # powerManagement = {
  #   enable = true;
  # };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  # Disabling nvidia.modesetting doesn't work if prime.offload is enabled
  boot.kernelParams = lib.mkMerge [
    (lib.mkIf (!config.hardware.nvidia.modesetting.enable)
      # last entries have priority, and the modeset=1 needs to be overriden
      (lib.mkAfter [ "nvidia-drm.modeset=0" ])
    )
    [
      # suspend loop fix
      "button.lid_init_state=open"
    ]
  ];

  environment.variables = {
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  hardware.nvidia = {
    package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
    nvidiaSettings = false;
    modesetting.enable = false;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      reverseSync = {
        enable = true;
      };
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:100:0:0"; # result of converting 64:0:0 to decimal
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
