{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  security.tpm2 = {
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

  security.pam.u2f = {
    control = "sufficient";
  };
}
