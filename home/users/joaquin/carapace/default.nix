{pkgs, ...}: let
  yaml = pkgs.formats.yaml {};
in {
  programs.carapace.enable = true;
  programs.carapace.aliases = {
    vi = "nvim";
    vim = "nvim";
    sail = ["docker" "compose"];
  };
  xdg.configFile."carapace/bridges.yaml".source = yaml.generate "bridges.yaml" {
    git = "fish";
    gpg = "fish";
    ykman = "fish";
    ssh = "fish";
  };

  home.sessionVariables = {
    # "CARAPACE_BRIDGES" = lib.concatStringsSep "," ["fish" "inshellisense"];
    # "CARAPACE_EXCLUDES" = lib.concatStringsSep "," ["gpg"];
    "CARAPACE_HIDDEN" = 1;
    "CARAPACE_LENIENT" = 1;
    "CARAPACE_MATCH" = 1; # 0 = case sensitive, 1 = case insensitive
    "CARAPACE_ENV" = 0; # disable get-env, del-env and set-env commands
  };
}
