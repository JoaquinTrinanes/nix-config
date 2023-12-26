{
  _file = ./.;
  hosts = {
    "razer-blade-14" = {
      system = "x86_64-linux";
      modules = [
        ../../hosts/razer-blade-14/default.nix
      ];
    };
    "media-server" = {
      system = "x86_64-linux";
      modules = [../../hosts/media-server/default.nix];
    };
  };
}
