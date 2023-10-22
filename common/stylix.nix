{
  pkgs,
  lib,
  ...
}: let
  theme = "catppuccin-frappe";
in {
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
      url = "https://cdn.discordapp.com/attachments/923640537356070972/1005882583348936774/5a266e448add93deab367d87173e9f25-683788614.png";
      hash = "sha256-bSHxrJI60pZi0ISpdG+4k8Wqp4bEH/VReWvACeO3E2Q=";
    };
    fonts = {
      monospace = {
        package =
          pkgs.nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];};
        name = "FiraCode Nerd Font";
      };
    };
  };
}
