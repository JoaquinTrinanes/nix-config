{self, ...}: {
  _file = ./home.nix;
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      homeManager = {
        enable = true;
        modules = [
          ../../home/users/joaquin
        ];
        hosts = {razer-blade-14 = true;};
        hostOverrides = {
          razer-blade-14 = osConfig: {config, ...}: {
            impurePath = {
              enable = true;
              flakePath = "${config.home.homeDirectory}/Documents/nix-config";
              repoUrl = "https://github.com/JoaquinTrinanes/nix-config.git";
            };
          };
        };
      };
    };
  };
  homeManager.sharedModules = [self.homeManagerModules.impurePath];
}
