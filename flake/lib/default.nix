{ inputs, lib, ... }:
{
  parts.nixpkgs.overlays = [
    (final: _prev: {
      my = {
        mkWrapper = inputs.wrapper-manager.lib.wrapWith final;
      };
    })
  ];
}
