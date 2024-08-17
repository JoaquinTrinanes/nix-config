{ lib, config, ... }:
let
  cfg = config.profiles.sshServer;
in
{
  options.profiles.sshServer = {
    enable = lib.mkEnableOption "ssh server profile";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = lib.mkDefault true;
      settings = {
        PermitEmptyPasswords = lib.mkDefault false;
        PasswordAuthentication = lib.mkDefault false;
        KbdInteractiveAuthentication = lib.mkDefault false;
        # PermitRootLogin = "yes";
      };
    };
  };
}
