{ pkgs, ... }: {

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.xserver.libinput.touchpad = {
    tapping = true;
    scrollMethod = "twofinger";
    naturalScrolling = true;
  };
}
