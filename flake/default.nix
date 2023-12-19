{...}: {
  _file = ./default.nix;

  imports = [
    ./modules
    ./configuration
  ];

  flake.flakeModules = {default = import ./modules;};
}
