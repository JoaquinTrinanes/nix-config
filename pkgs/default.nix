# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {inputs}: {
  # example = pkgs.callPackage ./example { };
  nushell-nightly = let
    craneLib = inputs.crane.lib.${pkgs.system};
    src = inputs.nushell-nightly-src;
  in
    pkgs.callPackage ./nushell-nightly {
      inherit src craneLib;
      additionalFeatures = p: (p ++ ["extra" "dataframe"]);
    };
}
