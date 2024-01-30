{
  _file = ./default.nix;
  imports = [./nixos.nix ./users.nix ./common.nix ./nixpkgs.nix ./overlays.nix];
}
