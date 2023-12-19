{
  _file = ./default.nix;

  imports = [
    ./common.nix
    ./nixpkgs.nix
    ./nixos.nix
    ./overlays.nix
    ./users.nix
  ];
}
