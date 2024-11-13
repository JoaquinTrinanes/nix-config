{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.hardware-acceleration;
  inherit (lib) types;
in
{
  options.profiles.hardware-acceleration = {
    enable = lib.mkEnableOption "hardware-acceleration profile";
    cpuType = lib.mkOption {
      type = types.enum [
        "intel"
        "amd"
      ];
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.cpuType == "amd") {
        environment.sessionVariables = {
          VDPAU_DRIVER = lib.mkDefault "radeonsi";
          LIBVA_DRIVER_NAME = lib.mkDefault "radeonsi";
        };
      })
      (lib.mkIf (cfg.cpuType == "intel") {
        hardware.graphics = {
          extraPackages = builtins.attrValues {
            inherit (pkgs)
              intel-media-driver # For Broadwell (2015) or newer processors. LIBVA_DRIVER_NAME=iHD
              intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
              ;
          };
        };
        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = lib.mkDefault "iHD"; # Optionally, set the environment variable
        };
      })
      {
        hardware.graphics = {
          enable = lib.mkDefault true;
          extraPackages = builtins.attrValues { inherit (pkgs) libva-vdpau-driver libvdpau-va-gl; };
          enable32Bit = lib.mkDefault true;
        };
      }
    ]
  );
}
