{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        rancho-wallpaper = pkgs.callPackage ./rancho-wallpaper.nix { };
      };
    };
}
