{pkgs, ...}: {
  services.pcscd.enable = true;
  services.udev.packages = [pkgs.yubikey-personalization];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubioath-flutter
    yubikey-personalization
    yubikey-personalization-gui
  ];
}
