{
  pkgs,
  lib,
  myLib,
  ...
}:
let
  yaml = pkgs.formats.yaml { };
in
{
  programs.carapace.enable = true;
  xdg.configFile."carapace/bridges.yaml".source = yaml.generate "bridges.yaml" {
    git = "fish";
    gpg = "fish";
    ykman = "fish";
    ssh = "fish";
  };
  programs.carapace.package = myLib.mkWrapper {
    basePackage = pkgs.carapace;
    pathAdd = [ pkgs.fish ];
    env = lib.mapAttrs (_: value: { value = toString value; }) {
      "CARAPACE_HIDDEN" = 1;
      "CARAPACE_LENIENT" = 1;
      "CARAPACE_MATCH" = 1; # 0 = case sensitive, 1 = case insensitive
      "CARAPACE_ENV" = 0; # disable get-env, del-env and set-env commands
    };
  };
}
