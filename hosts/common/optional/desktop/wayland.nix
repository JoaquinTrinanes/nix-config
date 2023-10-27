{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # bridge dep?
    xorg.libxcb.dev
    wl-clipboard
    xwaylandvideobridge
  ];
  environment.sessionVariables = {
    # GTK environment
    # GDK_BACKEND = "wayland"; # May cause problems with some xorg applications
    TDESKTOP_DISABLE_GTK_INTEGRATION = "1";
    CLUTTER_BACKEND = "wayland";
    BEMENU_BACKEND = "wayland";

    # Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # Qt environment
    QT_QPA_PLATFORM = "wayland-egl"; #error with apps xcb
    QT_WAYLAND_FORCE_DPI = "physical";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Elementary environment
    ELM_DISPLAY = "wl";
    ECORE_EVAS_ENGINE = "wayland_egl";
    ELM_ENGINE = "wayland_egl";
    ELM_ACCEL = "opengl";
    # ELM_SCALE = "1";

    # SDL environment
    SDL_VIDEODRIVER = "wayland";

    # Java environment
    _JAVA_AWT_WM_NONREPARENTING = "1";

    NO_AT_BRIDGE = "1";
    WINIT_UNIX_BACKEND = "wayland";
    # DBUS_SESSION_BUS_ADDRESS = "";
    # DBUS_SESSION_BUS_PID = "";
    NIXOS_OZONE_WL = "1";
  };
}
