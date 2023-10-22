{ pkgs, ... }: {

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  };
  environment.sessionVariables = { VDPAU_DRIVER = "radeonsi"; };
}
