{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        dynamic-gnome-wallpapers = pkgs.callPackage ./dynamic-gnome-wallpapers.nix {
          withDynamic = false;
        };
      };
    };
}
