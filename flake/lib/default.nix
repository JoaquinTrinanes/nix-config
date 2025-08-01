{ inputs, ... }:
{
  parts.nixpkgs.overlays = [
    (final: _prev: {
      my = {
        mkWrapper =
          module:
          let
            finalModule =
              if builtins.isAttrs module then
                (
                  {
                    # show the actual file that defines the wrapper in case of error
                    _file = (builtins.unsafeGetAttrPos "basePackage" module).file;
                  }
                  // module
                )
              else
                module;
          in
          inputs.wrapper-manager.lib.wrapWith final finalModule;
      };
    })
  ];
}
