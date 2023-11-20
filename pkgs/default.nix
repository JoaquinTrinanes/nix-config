# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: let
  inherit (pkgs) inputs outputs;
in {
  inherit pkgs;
  # example = pkgs.callPackage ./example { };
  nushell-nightly = let
    craneLib = inputs.crane.lib.${pkgs.system};
    inherit (inputs) nushell-nightly-src;
  in
    pkgs.callPackage ./nushell-nightly {
      src = nushell-nightly-src;
      inherit craneLib;
      additionalFeatures = p: (p ++ ["extra" "dataframe"]);
    };
}
