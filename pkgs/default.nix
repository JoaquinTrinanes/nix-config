# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: let
  inherit (pkgs) callPackage;
in {
  nushell-nightly = callPackage ./nushell-nightly {
    additionalFeatures = p: (p ++ ["extra" "dataframe"]);
    doCheck = false;
    inherit (pkgs.darwin.apple_sdk.frameworks) Libsystem Security AppKit;
  };
}
