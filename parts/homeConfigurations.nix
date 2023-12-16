_: {
  _file = ./homeConfigurations.nix;
  users = {
    "joaquin" = {
      email = "hi@joaquint.io";
      firstName = "Joaquín";
      lastName = "Triñanes";
      homeManager = {
        enable = true;
        modules = [
          ../home-manager/home.nix
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
