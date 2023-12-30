{lib, ...}: {
  networking = {
  };
  services.tailscale = {
    enable = true;
    extraUpFlags = lib.mkDefault ["--shields-up"];
  };
}
