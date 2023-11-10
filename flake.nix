{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    supportedSystems = ["x86_64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    mkNixosSystem = args:
      nixpkgs.lib.nixosSystem (args
        // {
          modules = [./hosts/common/global] ++ args.modules;
        });
  in {
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = forEachSystem (
      system: import ./pkgs nixpkgs.legacyPackages.${system}
    );

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter =
      forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

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
      razer-blade-14 = mkNixosSystem {
        specialArgs = {
          inherit inputs outputs;
          hostname = "razer-blade-14";
        };
        modules = [
          ./hosts/razer-blade-14
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = let
      pkgs =
        nixpkgs.legacyPackages.x86_64-linux;
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
          ({
            pkgs,
            lib,
            ...
          }: {
            nixpkgs = {
              overlays = [outputs.overlays.default];
              config.allowUnfree = lib.mkDefault true;
            };
          })
          ./home-manager/home.nix
        ];
      };
    };
  };
}
