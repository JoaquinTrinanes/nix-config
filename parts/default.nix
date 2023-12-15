{...}: {
  _file = ./default.nix;

  imports = [
    ./nix.nix
    ./nixpkgs.nix
    ./systems.nix
    ./users.nix
  ];
}
