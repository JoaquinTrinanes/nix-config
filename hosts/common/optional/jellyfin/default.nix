_: {
  systemd.tmpfiles.rules = [
    "d /mnt/media/Public/jellyfin 0755 jellyfin - - -"
  ];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
