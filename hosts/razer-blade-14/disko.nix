{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              label = "ESP";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "fmask=0022"
                  "dmask=0022"
                ];
                extraArgs = [
                  "-n"
                  "ESP"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                extraOpenArgs = [ ];
                extraFormatArgs = [
                  "--cipher=aes-xts-plain64"
                  "--hash=sha512"
                ];
                postCreateHook = ''
                  if [ "$(systemd-cryptenroll --fido2-device=list 2> /dev/null)" ]; then
                    shouldTryEnroll=""
                    read -r -p "FIDO2 device detected. Enroll? [y/N] " shouldTryEnroll
                    if [[ "$shouldTryEnroll" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                      echo 'Remember to touch the key after entering the PIN!' >&2
                      systemd-cryptenroll $device --fido2-device=auto  --fido2-with-client-pin=yes
                    fi
                    unset shouldTryEnroll
                  fi
                '';
                settings = { };
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              # type="filesystem";
              # format = "btrfs";
              mountpoint = "/";
              mountOptions = [
                "defaults"
                "compress=zstd"
                "noatime"
              ];
              subvolumes = {
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "32G";
                };
              };
            };
          };
        };
      };
    };
  };
}
