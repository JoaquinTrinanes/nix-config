{ ... }:
{
  imports = [ ./. ];
  environment.sessionVariables = {
    VDPAU_DRIVER = "radeonsi";
  };
}
