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
  steamNoInternet = pkgs.writeShellScriptBin "steam-no-internet" ''
    exec -a "$0" ${
      lib.getExe (
        steam.override (prev: {
          extraBwrapArgs = prev.extraBwrapArgs or [ ] ++ [ "--unshare-net" ];
        })
      )
    } "$@"
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

    programs.gamemode.enable = lib.mkDefault true;

    programs.steam = lib.mkDefault {
      enable = true;
      package = steam;
    };

    programs.firejail.wrappedBinaries =
      let
        wine = pkgs.wineWowPackages.stable;
        sandboxedWineProfile = pkgs.writeText "wine.profile" ''
          blacklist ''${HOME}
          include ${pkgs.firejail}/etc/firejail/wine.profile
        '';
      in
      {
        wine = {
          executable = lib.getExe' wine "wine";
          profile = sandboxedWineProfile;
        };
        wine64 = {
          executable = lib.getExe wine;
          profile = sandboxedWineProfile;
        };
        wineboot = {
          executable = lib.getExe' wine "wineboot";
        };
      };

    environment.systemPackages =
      lib.optionals cfg.steamNoInternet.enable [ steamNoInternet ]
      ++ builtins.attrValues {
        inherit (pkgs)
          heroic
          itch
          lutris
          mangohud
          winetricks
          ;
        inherit (pkgs.wineWowPackages) stable;
      };
  };
}
