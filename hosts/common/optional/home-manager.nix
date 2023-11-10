{
  inputs,
  outputs,
  lib,
  ...
}: let
  inherit ((import ../../../lib {inherit lib;})) mkUser;
  user = mkUser {
    name = "joaquin";
    email = "hi@joaquint.io";
    firstName = "Joaquín";
    lastName = "Triñanes";
  };
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    users."${user.name}" = ../../../home-manager/home.nix;
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit user inputs outputs;};
  };
}
