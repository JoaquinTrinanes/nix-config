{...}: {
  _file = ./default.nix;

  imports = [
    ./nix.nix
    ./nixpkgs.nix

    ./misc.nix
    ./overlays.nix
    ./substituters.nix

    ./nixos.nix
    ./users.nix

    ./nixosConfigurations.nix
    ./homeConfigurations.nix
  ];
}
