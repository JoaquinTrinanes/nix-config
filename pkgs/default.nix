# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  nushell-nightly = pkgs.callPackage ./nushell-nightly {
    additionalFeatures = p: (p ++ ["extra" "dataframe"]);
    doCheck = false;
  };
}
