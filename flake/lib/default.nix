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
  perSystem =
    { pkgs, lib, ... }:
    {
      _module.args.lib = lib.extend (
        final: _prev: {
          my = mkLib {
            inherit pkgs;
            lib = final;
          };
        }
      );
    };
}
