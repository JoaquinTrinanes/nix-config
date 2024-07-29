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
                  (
                    shouldTryEnroll=""
                    if [ "$(systemd-cryptenroll --fido2-device=list 2> /dev/null)" ]; then
                      read -r -p "FIDO2 device detected. Enroll? [y/N] " shouldTryEnroll
                      if [[ "$shouldTryEnroll" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                        systemd-cryptenroll $device --fido2-device=auto  --fido2-with-client-pin=yes
                      fi
                    fi
                  )
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
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs.root = {
        size = "100%FREE";
        content = {
          type = "btrfs";
          # mountpoint = "/";
          extraArgs = [ "-f" ]; # Override existing partition
          mountOptions = [ "defaults" ];
          subvolumes = {
            swap = {
              mountpoint = "/.swapvol";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              swap.swapfile.size = "32G";
            };
            # persist = {
            #   mountpoint = "/persist";
            #   mountOptions = [
            #     "defaults"
            #     "noatime"
            #     "compress=zstd"
            #   ];
            # };
            nix = {
              mountpoint = "/nix";
              mountOptions = [
                "defaults"
                "noatime"
                "compress=zstd"
              ];
            };
            rootfs = {
              mountpoint = "/";
              mountOptions = [
                "defaults"
                "noatime"
                "compress=zstd"
              ];
            };
            home = {
              mountpoint = "/home";
              mountOptions = [
                "defaults"
                "noatime"
                "compress=zstd"
              ];
            };
            var-log = {
              mountpoint = "/var/log";
              mountOptions = [
                "defaults"
                "noatime"
                "compress=zstd"
              ];
            };
          };
          postCreateHook = ''
            (
              MNTPOINT=$(mktemp -d)
              mount "$device" "$MNTPOINT" -o subvol=/
              trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
              btrfs subvolume snapshot -r $MNTPOINT/rootfs $MNTPOINT/rootfs-blank
            )
          '';
        };
      };
    };
  };
}
