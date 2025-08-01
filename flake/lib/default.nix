{ inputs, lib, ... }:
{
  parts.nixpkgs.overlays = [
    (final: _prev: {
      my = {
        mkWrapper =
          module:
          let
            finalModule =
              if builtins.isAttrs module && (builtins.length (builtins.attrNames module)) > 0 then
                {
                  # show the actual file that defines the wrapper in case of error
                  _file = (builtins.unsafeGetAttrPos (lib.head (builtins.attrNames module)) module).file;
                }
                // module

              else
                module;
          in
          inputs.wrapper-manager.lib.wrapWith final finalModule;
      };
    })
  ];
}
