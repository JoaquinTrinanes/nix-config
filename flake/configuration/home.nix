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
        # hosts = {
        #   ${hosts.razer-blade-14} = [
        #     ({pkgs, ...}: {
        #       home.packages = builtins.attrValues {inherit (pkgs) autofirma;};
        #     })
        #   ];
        # };
      };
    };
  };
}
