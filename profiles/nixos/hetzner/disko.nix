{
  lib,
  config,
  inputs,
  ...
}:
let
  hetznerCfg = config.profiles.hetzner;
  cfg = config.profiles.hetzner.disko;
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  options.profiles.hetzner.disko = {
    enable = lib.mkEnableOption "disko hetzner profile" // {
      default = hetznerCfg.enable;
      defaultText = lib.literalExpression "config.profiles.hetzner.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk.sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            esp = {
              size = "500M";
              type = "EF00"; # for grub MBR
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
