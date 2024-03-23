{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.carapace;
  yaml = pkgs.formats.yaml { };
  inherit (lib) types;
in
{
  options.programs.carapace = {
    specs = lib.mkOption {
      type = types.attrsOf yaml.type;
      apply = specs: lib.mapAttrs (name: value: { inherit name; } // value) specs;
      default = { };
    };
    aliases = lib.mkOption {
      type = types.attrsOf (types.either types.str (types.listOf types.str));
      apply = lib.mapAttrs (_: lib.toList);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.carapace.specs = lib.mapAttrs (_: value: {
      run = "[${lib.concatStringsSep ", " value}]";
    }) cfg.aliases;
    xdg.configFile = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "carapace/specs/${name}.yaml" { source = yaml.generate "${name}.yaml" value; }
    ) cfg.specs;
  };
}
