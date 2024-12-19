{ inputs, ... }:
let
  flakeModules = import ../modules/flake;
in
{
  _class = "flake";

  imports = builtins.attrValues flakeModules ++ [
    inputs.flake-parts.flakeModules.flakeModules
    ./parts
    ./home-configurations.nix
    ./misc.nix
    ./nixos-configurations.nix
    ./substituters.nix
    ./templates
    ./lib
    ./firefox
    ./neovim
  ];

  flake.modules = {
    flake = flakeModules;
    nixos = import ../modules/nixos;
    homeManager = import ../modules/home-manager;
  };
}
