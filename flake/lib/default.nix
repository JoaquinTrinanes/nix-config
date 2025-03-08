{
  parts.nixpkgs.overlays = [
    (final: _prev: {
      my = {
        mkWrapper = final.callPackage ./mkWrapper.nix { };
      };
    })
  ];
}
