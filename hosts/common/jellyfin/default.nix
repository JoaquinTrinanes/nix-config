_: {
  systemd.tmpfiles.rules = [
    "d /mnt/media/Public/jellyfin 1755 media - - -"
  ];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
