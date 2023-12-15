{
  config,
  lib,
  ...
}: let
  hosts = lib.genAttrs (builtins.attrNames (config.hosts)) (host: host);
in {
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      homeManager = {
        path = ./home.nix;
        hosts = {
          ${hosts.razer-blade-14} = true;
        };
      };
    };
  };
}
