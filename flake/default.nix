{...}: {
  _file = ./default.nix;

  imports = [
    ./modules
    ./configuration
  ];
}
