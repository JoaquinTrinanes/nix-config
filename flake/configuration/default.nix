_: {
  _file = ./default.nix;

  imports = [
    ./home.nix
    ./misc.nix
    ./substituters.nix
    ./nixosConfigurations.nix
  ];
}
