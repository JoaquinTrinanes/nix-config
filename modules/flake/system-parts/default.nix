{
  _class = "flake";
  imports = [
    ./nixos.nix
    ./users.nix
    ./common.nix
    ./nixpkgs.nix
  ];
}
