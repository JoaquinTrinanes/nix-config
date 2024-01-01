{
  networking = {
  };
  services.tailscale = {
    enable = true;
    # Disallow incoming connections by default, must be overriden with mkForce
    extraUpFlags = ["--shields-up"];
  };
}
