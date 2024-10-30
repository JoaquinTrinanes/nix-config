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
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    ./disko.nix
  ];

  profiles.hardware-acceleration = {
    enable = true;
    cpuType = "amd";
  };

  boot.initrd.systemd.enable = true;

  # avoid loading amdgpu at stage 1. Might reduce number of crashes on boot
  hardware.amdgpu.initrd.enable = false;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"

    # needed to run the zenstates c6 fix
    "msr"
  ];
  boot.supportedFilesystems = {
    ntfs = true;
    btrfs = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.efi.efiSysMountPoint = "/boot";

  environment.systemPackages = [
    (lib.mkIf config.hardware.nvidia.prime.offload.enable (
      pkgs.writeShellScriptBin "prime-run" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      ''
    ))
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = false;
  # networking.interfaces."enp101s0f3u1".useDHCP = true;
  networking.interfaces."wlan0".useDHCP = true;

  networking.usePredictableInterfaceNames = true;

  services.tlp = {
    enable = true;
    enable = false;
    settings = {
      # TLP_ENABLE = 0;
      RUNTIME_PM_ON_AC = "auto";
      USB_AUTOSUSPEND = 0;
      USB_EXCLUDE_BTUSB = 1;
    };
  };
  services.power-profiles-daemon.enable = false;
  services.power-profiles-daemon.enable = true;

  powerManagement = {
    enable = true;
  };

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  boot.kernelParams = lib.mkMerge [
    # Disabling nvidia.modesetting doesn't work if prime.offload is enabled
    (lib.mkIf (!config.hardware.nvidia.modesetting.enable)
      # last entries have priority, and the modeset=1 needs to be overriden
      (lib.mkAfter [ "nvidia-drm.modeset=0" ])
    )
    [
      # suspend loop fix
      "button.lid_init_state=open"
    ]
    [
      # https://wiki.archlinux.org/title/Ryzen#Soft_lock_freezing
      "rcu_nocbs=0-15" # https://bugs.launchpad.net/linux/+bug/1690085/comments/69

      # https://bugzilla.kernel.org/show_bug.cgi?id=196481
      # https://wiki.gentoo.org/wiki/Ryzen#Soft_freezes_on_1st_gen_Ryzen_7
      # "processor.max_cstate=5"

      # https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7
      "processor.max_cstate=3"

      "idle=nomwait"
      "pci=noaer"
      # "pci=nomsi,noaer" # nomsi probably makes the system unbootable
    ]
    [
      # https://forums.developer.nvidia.com/t/series-550-freezes-laptop/284772/45
      "amdgpu.vm_update_mode=3"
      "amdgpu.dcdebugmask=0x4"
    ]
  ];

  systemd.services."ryzen-disable-c6" = {
    description = "Ryzen Disable C6";
    after = [
      "sysinit.target"
      "local-fs.target"
      "suspend.target"
      "hibernate.target"
    ];
    before = [ "basic.target" ];
    wantedBy = [
      "basic.target"
      "suspend.target"
      "hibernate.target"
    ];
    unitConfig.DefaultDependencies = false;
    script = "${lib.getExe pkgs.zenstates} --c6-disable";
    serviceConfig.Type = "oneshot";
  };

  # Removing any of these prevents the dGPU from entering D3Cold
  environment.variables = {
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
    "__GLX_VENDOR_LIBRARY_NAME" = "mesa";
  };

  hardware.nvidia = {
    open = true;
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
    nvidiaSettings = lib.mkDefault false;
    modesetting.enable = lib.mkDefault false;
    powerManagement = lib.mkDefault {
      enable = true;
      finegrained = true;
    };
    prime = lib.mkDefault {
      reverseSync = {
        enable = true;
      };
      offload = {
        enable = true;
        enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
      };
      amdgpuBusId = "PCI:100:0:0"; # result of converting 64:0:0 to decimal
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
