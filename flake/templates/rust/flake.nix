{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      perSystem =
        { system, pkgs, ... }:
        let
          # rust = pkgs.rust-bin.selectLatestNightlyWith (
          #   toolchain:
          #   toolchain.default.override {
          #     extensions = [
          #       "rust-src"
          #       "rust-analyzer"
          #     ];
          #   }
          # );
          rust = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            overlays = [ inputs.rust-overlay.overlays.default ];
            inherit system;
          };

          devShells.default = pkgs.mkShell {
            packages = builtins.attrValues {
              inherit rust;
              inherit (pkgs) bashInteractive;
            };
          };
        };
    };
}
