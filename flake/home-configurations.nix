{ inputs, ... }:
{
  parts = {
    users = {
      "joaquin" = {
        home-manager = {
          enable = true;
          modules = [ ../home ];
        };
      };
    };
    home-manager = {
      modules = [
        ../home/global
        ../profiles/home-manager
      ]
      ++ builtins.attrValues inputs.self.modules.homeManager;
      standaloneModules = [ ../home/global/standalone.nix ];
    };
  };
}
