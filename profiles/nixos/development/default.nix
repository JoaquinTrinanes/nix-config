{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.development;
in
{
  options.profiles.development = {
    enable = lib.mkEnableOption "audio profile";
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = lib.mkDefault true;
    virtualisation.libvirtd.enable = lib.mkDefault true;

    virtualisation.docker = lib.mkDefault {
      enable = !(config.virtualisation.podman.enable && config.virtualisation.podman.dockerCompat);
      logDriver = "local";
      enableOnBoot = false;
    };

    virtualisation.podman = lib.mkDefault {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
      dockerSocket.enable = false;
    };
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        dbeaver-bin
        file
        gnome-boxes
        hyperfine
        pnpm
        scrcpy
        yarn-berry
        ;
    };

    # includes android-tools
    programs.adb.enable = true;
  };
}
