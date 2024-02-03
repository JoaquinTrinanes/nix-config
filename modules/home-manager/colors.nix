{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;
  cfg = config.colors;
  base16names =
    map
    (index: "base${lib.fixedWidthString 2 "0" (lib.toHexString index)}")
    (lib.range 0 15);
  hexColorType =
    types.coercedTo
    types.str (lib.removePrefix "#") (lib.mkOptionType {
      name = "hex-color";
      descriptionClass = "noun";
      description = "RGB color in hex format";
      check = x: lib.isString x && !(lib.hasPrefix "#" x) && lib.elem (lib.stringLength x) [3 6] && lib.strings.match "^[A-Fa-f0-9]+$" "aA" != null;
    });
  paletteType = types.submodule {
    freeformType = types.attrsOf hexColorType;
    options = lib.listToAttrs (map
      (name:
        lib.nameValuePair name (mkOption {type = hexColorType;}))
      base16names);
  };
  colorSchemeType =
    types.submodule
    ({config, ...}: let
      inherit (config) palette slug;
    in {
      options = {
        slug = mkOption {type = types.str;};
        author = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        name = mkOption {
          type = types.str;
          default = slug;
        };
        variant = mkOption {
          type = types.enum ["dark" "light"];
          default =
            if builtins.substring 0 1 palette.base00 < "5"
            then "dark"
            else "light";
        };
        mappings = mkOption {
          type = types.submodule {
            freeformType = types.unspecified;
            options.vim = {
              colorSchemeName = mkOption {
                type = types.nullOr types.str;
                default = slug;
              };
              package = {
                url = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                name = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
              };
            };
          };
          default = {};
        };
        alternate = mkOption {
          type = types.nullOr colorSchemeType;
          visible = "shallow";
          default = null;
        };
        palette = mkOption {type = paletteType;};
      };
    });
in {
  options.colors = {
    enable = lib.mkEnableOption "colorscheme management";
    colorScheme = mkOption {type = colorSchemeType;};
    colorSchemeAlternate = mkOption {
      type = types.nullOr colorSchemeType;
      default = cfg.colorScheme.alternate;
    };
  };
}
