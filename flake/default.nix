let
  flakeModules = import ../modules/flake;
in
{
  imports = builtins.attrValues flakeModules ++ [
    ./home-configurations.nix
    ./misc.nix
    ./nixos-configurations.nix
    ./substituters.nix
    ./templates
  ];

  flake.flakeModules = flakeModules;
}
