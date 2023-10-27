{pkgs, ...}: {
  # TODO: attr to override desired WM?
  imports = [./gnome.nix ./stylix.nix ../audio.nix];

  environment.systemPackages = with pkgs; [
    firefox
    discord
  ];
  programs.dconf.enable = true;

  xdg.portal.enable = true;
}
