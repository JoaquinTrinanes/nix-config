_: {
  systemd.tmpfiles.rules = [
    "d /mnt/media/Public/jellyfin 1755 jellyfin - - -"
  ];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
