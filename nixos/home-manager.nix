{ pkgs, inputs, outputs, ... }:
let user = "joaquin";
in {
  home-manager = {
    users.${user} = import ../home-manager/home.nix;
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
  };
  users.users.${user}.packages = with pkgs; [ home-manager ];
}
