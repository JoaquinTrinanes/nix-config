{
  config,
  lib,
  ...
}: let
  hosts = lib.genAttrs (builtins.attrNames (config.hosts)) (host: host);
in {
  _file = ./flake-module.nix;
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      homeManager = {
        enable = true;
        modules = [
          ./home.nix
        ];
        # hosts = {
        #   ${hosts.razer-blade-14} = [
        #     ({pkgs, ...}: {
        #       home.packages = builtins.attrValues {inherit (pkgs) autofirma;};
        #     })
        #   ];
        # };
      };
    };
  };
}
