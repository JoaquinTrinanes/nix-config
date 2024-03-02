let
  flakeModules = import ../modules/flake;
in {
  _file = ./default.nix;

  imports =
    builtins.attrValues flakeModules
    ++ [
      ./homeConfigurations.nix
      ./misc.nix
      ./nixosConfigurations.nix
      ./substituters.nix
    ];

  flake.flakeModules = flakeModules;
}
