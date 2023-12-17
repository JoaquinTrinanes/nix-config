{pkgs, ...}: {
  fonts.packages = with pkgs; [
    fira-code-nerdfont
    dejavu_fonts
    joypixels
    noto-fonts-cjk-sans
    unscii
  ];
  fonts.fontconfig = {
    defaultFonts = {
      monospace = ["FiraCode Nerd Font"];
      emoji = ["JoyPixels" "unscii:style=16-full"];
    };
    localConf = ''
      <match target="font">
        <test name="family" compare="eq" ignore-blanks="true">
          <string>FiraCode Nerd Font</string>
        </test>
        <edit name="fontfeatures" mode="append">
          <!-- @ style -->
          <string>ss05 on</string>
        </edit>
      </match>
    '';
  };

  nixpkgs.config.joypixels.acceptLicense = true;
}
