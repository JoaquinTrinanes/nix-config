{pkgs, ...}: {
  fonts.packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];}) joypixels];
  nixpkgs.config.joypixels.acceptLicense = true;
}
