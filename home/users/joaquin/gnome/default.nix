{pkgs, ...}: {
  imports = [./dconf.nix ./extensions.nix];
  # gtk = {
  #   enable = true;
  #   theme = {
  #     name = "WhiteSur";
  #     package = pkgs.whitesur-gtk-theme;
  #     # name = "palenight";
  #     # package = pkgs.palenight-theme;
  #     # name = "Orchis";
  #     # package = pkgs.orchis-theme;
  #     # name = "Flat-Remix-Miami";
  #     # package = pkgs.flat-remix-gtk;
  #     # name = "Catppuccin-Frappe-Standard-Blue-Dark";
  #     # package = pkgs.catppuccin-gtk.override {
  #     #   accents = ["blue"];
  #     #   size = "standard"; # compact
  #     #   tweaks = [];
  #     #   variant = "frappe";
  #     # };
  #   };
  # };
  # qt = {
  #   enable = true;
  #   platformTheme = "gtk";
  #   style.name = "adwaita-gtk";
  # };
  # home.sessionVariables.GTK_THEME = lib.mkIf config.gtk.enable config.gtk.theme.name;

  home.packages = builtins.attrValues {
    inherit (pkgs.gnome) gnome-tweaks;
    inherit (pkgs) paper-icon-theme;
  };

  # xdg.mimeApps = let
  #   getPkgHandler = pkg: let
  #     files = builtins.readDir "${pkg}/share/applications";
  #   in {};
  # in {
  #   enable = true;
  #   defaultApplications = {
  #     "text/plain" = let
  #       gnomeEditor = pkgs.gnome-text-editor;
  #       files = builtins.readDir "${gnomeEditor}/share/applications";
  #       desktopFiles = builtins.filterAttrs (name: value: value == "regular" && lib.hasSuffix ".desktop" name);
  #     in "";
  #   };
  # };
}
