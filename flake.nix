rec {
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.inputs.flake-parts.follows = "flake-parts";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nushell-nightly.url = "github:JoaquinTrinanes/nushell-nightly-flake";
    nushell-nightly.inputs.nixpkgs.follows = "nixpkgs";
    nushell-nightly.inputs.flake-parts.follows = "flake-parts";

    autofirma-nix.url = "github:nix-community/autofirma-nix";
    autofirma-nix.inputs.flake-parts.follows = "flake-parts";
    autofirma-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    jj.url = "github:jj-vcs/jj";
    jj.inputs.nixpkgs.follows = "nixpkgs";

    wrapper-manager.url = "github:viperML/wrapper-manager";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nushell-nightly.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [ ./flake ];

      _module.args = {
        inherit nixConfig;
      };
    };
}
