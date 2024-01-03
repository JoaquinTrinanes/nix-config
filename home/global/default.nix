{self, ...}: {
  imports = [
    self.homeManagerModules.impurePath
  ];
  programs.ssh = {
    includes = ["config.local"];
  };
}
