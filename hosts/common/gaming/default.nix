{ pkgs, lib, ... }:
let
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
in
{
  programs.steam.enable = true;
  programs.steam.package = steamPackages.steam-fhsenv;
}
