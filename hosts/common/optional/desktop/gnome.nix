{pkgs, ...}: {
  imports = [./wayland.nix];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.xserver.libinput.touchpad = {
    tapping = true;
    scrollMethod = "twofinger";
    naturalScrolling = true;
  };

  environment.systemPackages = with pkgs;
    (with gnome; [gnome-tweaks adwaita-icon-theme])
    ++ (with gnomeExtensions; [appindicator dash-to-panel espresso night-theme-switcher]);

  environment.gnome.excludePackages = with pkgs;
  with pkgs.gnome; [
    # baobab # disk usage analyzer
    # cheese # photo booth
    # eog # image viewer
    epiphany # web browser
    # gedit # text editor
    simple-scan # document scanner
    totem # video player
    yelp # help viewer
    # evince # document viewer
    # file-roller # archive manager
    geary # email client
    # seahorse # password manager

    # gnome-calculator
    # gnome-calendar
    # gnome-characters
    # gnome-clocks
    gnome-contacts
    gnome-connections
    # gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    # gnome-photos
    # gnome-screenshot
    # gnome-system-monitor
    gnome-tour
    gnome-weather
  ];
}
