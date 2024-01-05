{
  _file = ./default.nix;

  imports = [
    ./home.nix
    ./misc.nix
    ./nixosConfigurations.nix
    ./substituters.nix
  ];
}
