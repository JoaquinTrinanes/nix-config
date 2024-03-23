let
  flakeModules = import ../modules/flake;
in
{
  imports = builtins.attrValues flakeModules ++ [
    ./homeConfigurations.nix
    ./misc.nix
    ./nixosConfigurations.nix
    ./substituters.nix
  ];

  flake.flakeModules = flakeModules;
}
