{inputs, ...}: {
  imports = [inputs.stylix.nixosModules.stylix ../../../../common/stylix.nix];
  stylix.targets.gnome.enable = false;
}