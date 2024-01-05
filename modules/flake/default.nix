let
  modules = {
    common = ./common.nix;
    nixpkgs = ./nixpkgs.nix;
    nixos = ./nixos.nix;
    overlays = ./overlays.nix;
    users = ./users.nix;
  };
in
  {
    _file = ./default.nix;

    default = {imports = builtins.attrValues modules;};
  }
  // modules
