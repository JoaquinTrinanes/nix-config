{ config, ... }:
{
  parts = {
    users = {
      "joaquin" = {
        enable = true;
        modules = [ ../home ];
      };
    };
    home-manager = {
      modules = [
        ../home/global
        ../profiles/home-manager
      ]
      ++ builtins.attrValues config.flake.modules.homeManager;
      standaloneModules = [ ../home/global/standalone.nix ];
    };
  };
}
