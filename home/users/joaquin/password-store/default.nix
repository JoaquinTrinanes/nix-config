{pkgs, ...}: {
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (extensions:
      builtins.attrValues {
        inherit
          (extensions)
          pass-otp
          pass-import
          ;
      });
  };

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      qtpass
      ;
  };
}
