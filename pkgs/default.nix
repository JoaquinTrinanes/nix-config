# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  autofirma = pkgs.callPackage ./autofirma {
    jre = pkgs.jre8;
  };
  dynamic-gnome-wallpapers = pkgs.callPackage ./dynamic-gnome-wallpapers {};
}
