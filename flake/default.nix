let
  flakeModules = import ../modules/flake;
in {
  _file = ./default.nix;

  imports = [
    flakeModules.default
    ./home.nix
    ./misc.nix
    ./nixosConfigurations.nix
    ./substituters.nix
  ];

  flake.flakeModules = flakeModules;
}
