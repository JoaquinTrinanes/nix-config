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
      mkUser = {
        name,
        email,
        firstName ? name,
        lastName ? null,
        fullName ? builtins.concatStringsSep " " (builtins.filter (x: x != null) [firstName lastName]),
      }: {
        inherit name email firstName lastName fullName;
      };
      mkNixosHomeManagerModule = user: home: {myLib, ...}: {
        imports = [inputs.home-manager.nixosModules.home-manager];
        home-manager = {
          users."${user.name}" = home;
          useUserPackages = true;
          useGlobalPkgs = true;
          extraSpecialArgs = {inherit user inputs self;};
        };
      };
      users = {
        joaquin = mkUser {
          name = "joaquin";
          email = "hi@joaquint.io";
          firstName = "Joaquín";
          lastName = "Triñanes";
        };
      };
      commonNixpkgsConfig = {
        nixpkgs = {
          overlays = [self.overlays.default];
          config.allowUnfree = true;
        };
      };
      pkgsForSystem = system:
        import nixpkgs ({
            inherit system;
          }
          // commonNixpkgsConfig.nixpkgs);
    in {
      debug = true;
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages = import ./pkgs pkgs;
        formatter = pkgs.alejandra;
        _module.args.pkgs = pkgsForSystem system;
      };

      imports = [
        ./overlays
      ];

      flake = {
        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home-manager;

        flakeModules = import ./modules/flake;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          razer-blade-14 = lib.nixosSystem {
            specialArgs = {
              inherit inputs self;
            };
            modules = [
              (mkNixosHomeManagerModule users.joaquin ./home-manager/home.nix)
              commonNixpkgsConfig
              {networking.hostName = "razer-blade-14";}
              ./hosts/razer-blade-14
              ./hosts/common/global
            ];
          };
          media-box = lib.nixosSystem {
            specialArgs = {
              inherit inputs self;
            };
            modules = [
              commonNixpkgsConfig
              {networking.hostName = "media-box";}
              ./hosts/media-server
              ./hosts/common/global
            ];
          };
        };

        # Standalone home-manager configuration entrypoint
        # Available through 'home-manager --flake .#your-username@your-hostname'
        homeConfigurations = let
          user = users.joaquin;
          mkHomeConfig = path: {
            pkgs,
            osConfig ? null,
          }:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs user self osConfig;
              };
              modules = [path];
            };
        in
          # Create user@hostname for all hosts, plus a standalone user with osConfig set to null
          lib.mergeAttrs {
            ${user.name} = mkHomeConfig ./home-manager/home.nix {pkgs = pkgsForSystem "x86_64-linux";};
          }
          (lib.mapAttrs' (
              host: hostConfig:
                lib.nameValuePair "${user.name}@${host}" (mkHomeConfig ./home-manager/home.nix {
                  inherit (hostConfig) pkgs;
                  osConfig = hostConfig.config;
                })
            )
            self.nixosConfigurations);
      };
    });
}
