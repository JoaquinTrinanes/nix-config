{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    nushell-nightly-src.url = "github:nushell/nushell";
    nushell-nightly-src.flake = false;

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    ...
  }: let
    inherit (self) outputs;
  in
    flake-parts.lib.mkFlake {inherit inputs;} (let
      overlays = [outputs.overlays.default];
      pkgsForSystem = system:
        import nixpkgs {
          inherit system overlays;
          nixpkgs.config.allowUnfree = true;
        };
      commonConfigModule = _: {
        nixpkgs = {
          inherit overlays;
          config.allowUnfree = true;
        };
      };
    in {
      debug = true;
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;
        packages = import ./pkgs pkgs {inherit inputs outputs;};
        _module.args.pkgs = pkgsForSystem system;
      };

      flake = {
        # Your custom packages and modifications, exported as overlays
        overlays = import ./overlays {inherit inputs outputs;};

        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home-manager;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          razer-blade-14 = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs;
              hostname = "razer-blade-14";
            };
            modules = [
              commonConfigModule
              ./hosts/razer-blade-14
              ./hosts/common/global
            ];
          };
        };

        # Standalone home-manager configuration entrypoint
        # Available through 'home-manager --flake .#your-username@your-hostname'
        homeConfigurations = let
          pkgs = pkgsForSystem "x86_64-linux";
          myLib = import ./lib {inherit (pkgs) lib;};
          user = myLib.mkUser {
            name = "joaquin";
            email = "hi@joaquint.io";
            firstName = "Joaquín";
            lastName = "Triñanes";
          };
        in {
          "joaquin" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs outputs user;
              osConfig = {};
            };
            modules = [
              commonConfigModule
              ./home-manager/home.nix
            ];
          };
        };
      };
    });
}
