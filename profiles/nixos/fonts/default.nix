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
      dejavu_fonts
      joypixels
      noto-fonts-cjk-sans
      unscii
      nerd-fonts.symbols-only
    ];
    fonts.fontconfig = lib.mkDefault {
      defaultFonts = {
        monospace = [
          "FiraCode Nerd Font"
          "Noto Sans Mono CJK HK"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK KR"
        ];
        emoji = [
          "JoyPixels"
          "Symbols Nerd Font"
          "unscii-16-full"
        ];
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
      };
      localConf =
        let
          fontConfigByFamily = {
            "FiraCode Nerd Font" = {
              features = {
                # @ style
                ss05 = true;
              };
            };
          };
          mkFontConfig =
            font:
            {
              features ? { },
            }:
            ''
              <match target="font">
                <test name="family" compare="eq" ignore-blanks="true">
                  <string>${lib.escapeXML font}</string>
                </test>
                <edit name="fontfeatures" mode="append">
                  ${lib.concatMapAttrsStringSep "\n" (
                    name: value: "<string>${lib.escapeXML name} ${if value then "on" else "off"}</string>"
                  ) features}
                </edit>
              </match>
            '';
        in
        ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            ${lib.concatMapAttrsStringSep "\n" mkFontConfig fontConfigByFamily}
          </fontconfig>
        '';
    };

    nixpkgs.config.joypixels.acceptLicense = true;
  };
}
