{pkgs, ...}: {
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [vaapiVdpau libvdpau-va-gl];
  };
}
