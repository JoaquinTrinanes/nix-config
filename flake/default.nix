let
  flakeModules = import ../modules/flake;
in
{
  _class = "flake";

  imports = builtins.attrValues flakeModules ++ [
    ./home-configurations.nix
    ./misc.nix
    ./nixos-configurations.nix
    ./substituters.nix
    ./templates
  ];

  flake.flakeModules = flakeModules;
}
