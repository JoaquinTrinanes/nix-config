{ inputs, ... }:
let
  mkLib =
    { pkgs, lib }:
    {
      mkWrapper =
        {
          basePackage,
          name ? basePackage.name or basePackage.pname,
          ...
        }@args:
        let
          options = lib.attrsets.removeAttrs args [ "name" ];
          inherit (inputs) wrapper-manager;
          wrapper = wrapper-manager.lib.build {
            inherit pkgs;
            modules = [
              {
                _file = ./default.nix;
                wrappers.${name} = options;
              }
            ];
          };
        in
        wrapper.overrideAttrs (
          _final: _prev:
          lib.recursiveUpdate
            (lib.filterAttrs (
              name: _value:
              lib.elem name [
                "pname"
                "name"
                "version"
                "passthru"
                "meta"
              ]
            ) basePackage)
            {
              passthru = {
                unwrapped = basePackage;
              };
              meta = {
                outputsToInstall = [ "out" ];
                outputs = [ "out" ];
              };
            }

        );
    };
in
{
  system-parts.common.modules = [
    (
      {
        lib,
        pkgs,
        config,
        ...
      }:
      let
        myLib = mkLib { inherit pkgs lib; };
      in
      {
        _file = ./default.nix;
        lib.my = myLib;
        _module.args.myLib = config.lib.my;
      }
    )
  ];
}
