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
        substituters = lib.mkIf (lib.hasAttr "extra-substituters" nixConfig) (
          lib.mkAfter nixConfig.extra-substituters
        );
        trusted-public-keys = lib.mkIf (
          nixConfig ? extra-trusted-public-keys
        ) nixConfig.extra-trusted-public-keys;
      }
      {
        substituters = lib.mkAfter [
          "https://numtide.cachix.org"
        ];
        trusted-public-keys = [
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        ];
      }
    ];
  };
in
{
  parts.common.exclusiveModules = [ substituterSettingsModule ];
}
