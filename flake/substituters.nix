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
          "https://cache.numtide.com"
        ];
        trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      }
    ];
  };
in
{
  parts.common.exclusiveModules = [ substituterSettingsModule ];
}
