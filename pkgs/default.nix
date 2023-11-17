# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  nushell-nightly = pkgs.callPackage ./nushell-nightly {
    src = pkgs.nushell-nightly;
    additionalFeatures = p: (p ++ ["extra" "dataframe"]);
  };
}
