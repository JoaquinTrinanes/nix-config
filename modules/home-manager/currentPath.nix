{
  lib,
  config,
  ...
}: {
  options.my = with lib; {
    currentPath = mkOption {
      type = types.nullOr types.str;
      default = "${config.home.homeDirectory}/Documents/nix-config";
    };
  };
}
