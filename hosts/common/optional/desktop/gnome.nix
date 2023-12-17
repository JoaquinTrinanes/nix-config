{pkgs, ...}: {
  imports = [./wayland.nix];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    libinput.touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
    };
  };
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) pinentry-gnome;
    inherit (pkgs.gnome) gnome-tweaks adwaita-icon-theme;
    inherit
      (pkgs.gnomeExtensions)
      appindicator
      dash-to-panel
      espresso
      night-theme-switcher
      ;
  };

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
