{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.yubikey;
in
{
  options.profiles.yubikey = {
    enable = lib.mkEnableOption "yubikey profile";
  };

  config = lib.mkIf cfg.enable {
    services.pcscd.enable = lib.mkDefault true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    security.tpm2 = lib.mkDefault {
      enable = true;
      tctiEnvironment.enable = true;
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubioath-flutter
      yubikey-personalization
      yubikey-personalization-gui
    ];

    # security.pam.yubico = {
    #   enable = lib.mkDefault true;
    #   control = "sufficient";
    #   mode = "challenge-response";
    #   id = [ ];
    # };

    security.pam.u2f = lib.mkDefault { control = "sufficient"; };
  };
}
