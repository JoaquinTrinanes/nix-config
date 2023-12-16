{
  pkgs,
  self,
  ...
}: {
  imports = [
    ./gnome.nix
    ../audio.nix
    ../fonts.nix
    ../printing.nix
  ];

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      discord
      qbittorrent
      telegram-desktop
      vlc
      ;
    inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) autofirma;
  };
  programs.dconf.enable = true;
  programs.firefox = {
    nativeMessagingHosts.packages = with pkgs; [enpass];
  };

  xdg.portal.enable = true;
}
