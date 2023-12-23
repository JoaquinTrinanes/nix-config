{
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.firefox-devedition;
    profiles = {
      "dev-edition-default" = {
        id = 0;
        isDefault = true;
      };
      "default" = {
        id = 1;
      };
    };
  };
}
