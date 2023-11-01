{
  inputs,
  outputs,
  lib,
  ...
}: let
  inherit ((import ../../../lib {inherit lib;})) mkHomeManagerUser;
  user = {
    name = "joaquin";
    email = "hi@joaquint.io";
    firstName = "Joaquín";
    lastName = "Triñanes";
  };
in {
  imports = [inputs.home-manager.nixosModules.home-manager (mkHomeManagerUser user ../../../home-manager/home.nix)];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs outputs;};
  };
}
