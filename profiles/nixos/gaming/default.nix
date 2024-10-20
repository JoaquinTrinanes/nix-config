{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.gaming;
  # Don't launch steam with the dGPU
  steam = pkgs.steam.override (prev: {
    steam-unwrapped = prev.steam-unwrapped.overrideAttrs (prevUnwrapped: {
      postInstall = lib.concatLines [
        prevUnwrapped.postInstall
        ''
          substituteInPlace $out/share/applications/steam.desktop \
            --replace-fail PrefersNonDefaultGPU=true PrefersNonDefaultGPU=false \
            --replace-fail X-KDE-RunOnDiscreteGpu=true X-KDE-RunOnDiscreteGpu=false 
        ''
      ];
    });
  });
  steamNoInternet =
    let
      steamNoInternetPkg = steam.override (prev: {
        steam-unwrapped = prev.steam-unwrapped.overrideAttrs (prevUnwrapped: {
          extraBwrapArgs = (prevUnwrapped.args.extraBwrapArgs or [ ]) ++ [ "--unshare-net" ];
        });
      });
    in
    pkgs.writeShellScriptBin "steam-no-internet" ''
      exec -a "$0" ${lib.getExe steamNoInternetPkg} "$@"
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
      package = steam;
    };
    environment.systemPackages =
      lib.optionals cfg.steamNoInternet.enable [ steamNoInternet ]
      ++ builtins.attrValues {
        inherit (pkgs)
          lutris
          # itch
          ;
      };
  };
}
