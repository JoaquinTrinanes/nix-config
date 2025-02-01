{
  lib,
  config,
  modulesPath,
  pkgs,
  ...
}:
let
  cfg = config.profiles.hetzner;
in
{
  imports = [
    ./cloud-init.nix
    ./disko.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  options.profiles.hetzner = {
    enable = lib.mkEnableOption "hetzner profile";
  };

  config = lib.mkIf cfg.enable {
    boot.growPartition = true;
    boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];

    networking.useNetworkd = true;
    networking.useDHCP = false;

    # Needed by the Hetzner Cloud password reset feature.
    services.qemuGuest.enable = lib.mkDefault true;
    # https://discourse.nixos.org/t/qemu-guest-agent-on-hetzner-cloud-doesnt-work/8864/2
    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];
  };
}
