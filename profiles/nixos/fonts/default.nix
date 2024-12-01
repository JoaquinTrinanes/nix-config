{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.fonts;
in
{
  options.profiles.fonts = {
    enable = lib.mkEnableOption "fonts profile";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      maple-mono
      dejavu_fonts
      joypixels
      noto-fonts
      noto-fonts-cjk-sans
      unscii
      nerd-fonts.symbols-only
    ];
    fonts.fontconfig = lib.mkDefault {
      defaultFonts = {
        monospace = [
          "Maple Mono"
          # "FiraCode Nerd Font"
        ];
        emoji = [
          "JoyPixels"
          "unscii-16-full"
        ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="font">
            <test name="family" compare="eq" ignore-blanks="true">
              <string>FiraCode Nerd Font</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <!-- @ style -->
              <string>ss05 on</string>
            </edit>
          </match>
          <match target="font">
            <test name="family" compare="eq" ignore-blanks="true">
              <string>Maple Mono</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <!-- @,#,$,%... style -->
              <string>cv01 on</string>
              <!-- a style -->
              <string>cv03 on</string>
              <!-- @ style -->
              <string>cv04 on</string>
              <!-- == ligatures -->
              <string>ss01 on</string>
              <!-- [TODO] pills (test) -->
              <string>ss02 on</string>
              <!-- <= ligatures -->
              <string>ss04 on</string>
              <!-- {{ }} ligatures -->
              <string>ss05 on</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };

    nixpkgs.config.joypixels.acceptLicense = true;
  };
}
