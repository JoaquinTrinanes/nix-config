{pkgs, ...}: {
  programs.password-store.package = pkgs.passage;
  home.shellAliases = {
    "pass" = "passage";
    "age" = "rage";
    "age-keygen" = "rage-keygen";
  };

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      rage
      passage
      ;
  };
}
