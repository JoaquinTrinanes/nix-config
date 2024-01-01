{self, ...}: {
  _file = ./.;
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      sshPublicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCutbKZk+mbku2/ndSociCACyV+Joc0QVYRfjxAHW79 openpgp:0x31C20393"
      ];
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
