let
  flakeModules = import ../modules/flake;
in
{
  _class = "flake";

  imports = builtins.attrValues flakeModules ++ [
    ./parts
    ./home-configurations.nix
    ./misc.nix
    ./nixos-configurations.nix
    ./substituters.nix
    ./templates
    ./lib
    ./neovim
  ];

  flake.flakeModules = flakeModules;
}
