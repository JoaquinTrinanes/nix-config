_: {
  _file = ./nixosConfigurations.nix;
  hosts = {
    "razer-blade-14" = {
      system = "x86_64-linux";
      modules = [
        ../../hosts/razer-blade-14/default.nix
      ];
    };
    "media-box" = {
      system = "x86_64-linux";
      modules = [../../hosts/media-server/default.nix];
    };
  };
}
