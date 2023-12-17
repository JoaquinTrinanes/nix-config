{lib, ...}: let
  modules = {
    nix = ./nix.nix;
    nixpkgs = ./nixpkgs.nix;
    nixos = ./nixos.nix;
    overlays = ./overlays.nix;
    users = ./users.nix;
  };
in {
  _file = ./default.nix;

  imports = builtins.attrValues modules;

  flake.flakeModules = lib.mapAttrs (_: import) modules;
}
