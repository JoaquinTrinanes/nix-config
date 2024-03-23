{ lib, config, ... }:
let
  inherit (config.system-parts) flake-nix-config;
  substituterSettings.nix.settings = lib.mkMerge [
    {
      substituters = flake-nix-config.extra-substituters;
      trusted-public-keys = flake-nix-config.extra-trusted-public-keys;
    }
    {
      substituters = [
        "https://numtide.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    }
  ];
in
{
  system-parts.common.exclusiveModules = [ substituterSettings ];
}
