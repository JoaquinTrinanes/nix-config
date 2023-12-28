{pkgs, ...}: {
  programs.password-store.enable = true;

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      qtpass
      ;
  };
}
