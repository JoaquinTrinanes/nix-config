{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.gaming;
  # Don't launch steam with the dGPU
  steamPackages = pkgs.steamPackages.overrideScope (
    _steamPkgsFinal: steamPkgsPrev: {
      steam = steamPkgsPrev.steam.overrideAttrs (
        _final: prev: {
          postInstall = lib.concatLines [
            prev.postInstall
            ''
              substituteInPlace $out/share/applications/steam.desktop \
              --replace-fail PrefersNonDefaultGPU=true PrefersNonDefaultGPU=false \
              --replace-fail X-KDE-RunOnDiscreteGpu=true X-KDE-RunOnDiscreteGpu=false
            ''
          ];
        }
      );
    }
  );
  steamPackagesNoInternet = steamPackages.overrideScope (
    _steamPkgsFinal: steamPkgsPrev: {
      steam-fhsenv = steamPkgsPrev.steam-fhsenv.override (prev: {
        extraBwrapArgs = (prev.extraBwrapArgs or [ ]) ++ [ "--unshare-net" ];
      });
    }
  );
  steamNoInternet = pkgs.writeShellScriptBin "steam-no-internet" ''
    exec -a "$0" ${lib.getExe steamPackagesNoInternet.steam-fhsenv} "$@"
  '';
in
{
  options.profiles.gaming = {
    enable = lib.mkEnableOption "gaming profile";
    steamNoInternet.enable = lib.mkEnableOption "steam without internet access" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ns-usbloader.enable = lib.mkDefault true;

    programs.steam = lib.mkDefault {
      enable = true;
      package = steamPackages.steam-fhsenv;
    };

    environment.systemPackages = lib.mkIf cfg.steamNoInternet.enable [ steamNoInternet ];
  };
}
