{inputs, ...}: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  colors = let
    catppuccin-frappe =
      colorSchemes.catppuccin-frappe
      // {
        alternate = catppuccin-latte;
        mappings = {
          vim = {
            package = {
              url = "catppuccin/nvim";
              name = "catppuccin";
            };
          };
        };
      };
    catppuccin-latte =
      colorSchemes.catppuccin-latte
      // {
        alternate = catppuccin-frappe;
      };
  in {
    enable = true;
    colorScheme = catppuccin-frappe;
    colorSchemeAlternate = null;
  };
}
