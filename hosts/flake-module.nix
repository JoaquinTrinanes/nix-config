_: {
  _file = ./flake-module.nix;
  hosts = {
    "razer-blade-14" = {
      system = "x86_64-linux";
      modules = [
        ./razer-blade-14/default.nix
      ];
    };
    "media-box" = {
      system = "x86_64-linux";
      modules = [./media-server/default.nix];
    };
  };
}
