_: {
  _file = ./home.nix;
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      homeManager = {
        enable = true;
        modules = [
          ../../home
        ];
        hostOverrides = {
          razer-blade-14 = osConfig: {
            # programs.neovim.enable = osConfig.programs.firefox.enable;
          };
        };
      };
    };
  };
}
