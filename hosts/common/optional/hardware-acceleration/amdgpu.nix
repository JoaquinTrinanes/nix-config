{...}: {
  imports = [./default.nix];
  environment.sessionVariables = {VDPAU_DRIVER = "radeonsi";};
}
