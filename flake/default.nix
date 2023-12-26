{...}: {
  _file = ./.;

  imports = [
    ./modules
    ./configuration
  ];

  flake.flakeModules = {default = import ./modules;};
}
