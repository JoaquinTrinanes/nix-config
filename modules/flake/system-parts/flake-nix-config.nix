{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.system-parts.flake-nix-config = mkOption {
    type = types.submodule ({config, ...}: {
      freeformType = types.attrsOf types.unspecified;

      options = {
        extra-substituters = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
        };

        extra-trusted-public-keys = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
        };
      };
    });
    default = {};
  };
}
