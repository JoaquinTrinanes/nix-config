{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nushell-nightly.url = "github:JoaquinTrinanes/nushell-nightly-flake";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (let
      inherit (nixpkgs) lib;
    in {
      debug = true;
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages = import ./pkgs pkgs;
        formatter = pkgs.writeShellScriptBin "alejandra" ''
          exec ${lib.getExe pkgs.alejandra} --quiet "$@"
        '';
      };

      imports = [
        ./parts
        ./overlays
        ./hosts/flake-module.nix
        ./home-manager/flake-module.nix
      ];

      flake = {
        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home-manager;

        # flakeModules = import ./modules/flake;
      };
    });
}
