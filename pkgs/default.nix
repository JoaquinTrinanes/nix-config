{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        dynamic-gnome-wallpapers = pkgs.callPackage ./dynamic-gnome-wallpapers.nix { };
        foo2zjs = pkgs.callPackage ./foo2zjs { };
      };
    };
}
