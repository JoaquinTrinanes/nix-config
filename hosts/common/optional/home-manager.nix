{
  pkgs,
  outputs,
  inputs,
  ...
}: let
  user = "joaquin";
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    users.${user} = ../../../home-manager/home.nix;
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs outputs;};
  };
  users.users.${user}.packages = with pkgs; [home-manager];
}
