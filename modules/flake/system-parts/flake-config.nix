{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.system-parts.flake-config = mkOption {
    type = types.attrsOf types.unspecified;
    default = {};
  };
}
