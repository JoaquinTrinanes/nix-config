{
  lib,
  nixConfig ? { },
  ...
}:
let
  substituterSettingsModule = {
    _file = ./substituters.nix;
    nix.settings = lib.mkMerge [
      {
        substituters = lib.mkIf (nixConfig ? extra-substituters) (lib.mkAfter nixConfig.extra-substituters);
        trusted-public-keys = lib.mkIf (
          nixConfig ? extra-trusted-public-keys
        ) nixConfig.extra-trusted-public-keys;
      }
      {
        substituters = lib.mkAfter [
          "https://numtide.cachix.org"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      }
    ];
  };
in
{
  parts.common.exclusiveModules = [ substituterSettingsModule ];
}
