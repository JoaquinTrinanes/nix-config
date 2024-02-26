{pkgs, ...}: {
  services.pcscd.enable = true;
  services.udev.packages = [pkgs.yubikey-personalization];

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubioath-flutter
    yubikey-personalization
    yubikey-personalization-gui
  ];
}
