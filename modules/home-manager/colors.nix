{ lib, config, ... }:
let
  cfg = config.colors;
  inherit (lib) types;
  hexColorType = lib.mkOptionType {
    name = "hex-color";
    descriptionClass = "noun";
    description = "RGB color in hex format";
    check = x: lib.isString x && !(lib.hasPrefix "#" x);
  };
in
{
  options.colors = {
    name = lib.mkOption { type = types.nullOr types.str; };
    palette = lib.mkOption {
      type = types.attrsOf (types.coercedTo types.str (lib.removePrefix "#") hexColorType);
      default = { };
    };
    slug = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    variant = lib.mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      default =
        if !cfg.palette ? base00 || builtins.substring 0 1 cfg.palette.base00 < "5" then
          "dark"
        else
          "light";
      defaultText = lib.literalExpression ''
        if builtins.substring 0 1 cfg.palette.base00 < "5" then "dark" else "light";
      '';
    };
  };

  config.colors = {
    name = lib.mkOptionDefault cfg.slug;
  };
}
