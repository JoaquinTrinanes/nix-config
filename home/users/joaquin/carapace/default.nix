{
  pkgs,
  lib,
  config,
  ...
}:
let
  yaml = pkgs.formats.yaml { };
  bridges = {
    git = "fish";
    gpg = "fish";
    ykman = "fish";
    ssh = "fish";
  };
in
{
  programs.carapace = {
    enable = true;
    enableFishIntegration = false;
    package = pkgs.my.mkWrapper {
      basePackage = pkgs.carapace;
      pathAdd = [ config.programs.fish.package ];
      env =
        lib.mapAttrs
          (_: value: {
            value = toString value;
            force = false;
          })
          {
            CARAPACE_EXCLUDES = lib.concatStringsSep "," ((builtins.attrNames bridges) ++ [ "man" ]);
            CARAPACE_HIDDEN = 1;
            CARAPACE_LENIENT = 1;
            CARAPACE_MATCH = 1; # 0 = case sensitive, 1 = case insensitive
            CARAPACE_ENV = 0; # disable get-env, del-env and set-env commands
          };
    };
  };
  xdg.configFile."carapace/bridges.yaml".source = yaml.generate "bridges.yaml" bridges;
}
