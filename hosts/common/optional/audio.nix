{
  pkgs,
  lib,
  ...
}: {
  # sound
  security.rtkit.enable = true;
  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf --experimental"
  ];
  environment.systemPackages = with pkgs; [pavucontrol];
}
