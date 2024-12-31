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
          "FiraCode Nerd Font"
          "Maple Mono"
          "Noto Sans Mono CJK HK"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK KR"
        ];
        emoji = [
          "JoyPixels"
          "Symbols Nerd Font Mono"
          "unscii-16-full"
        ];
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
            "Maple Mono" = {
              features = {
                # @,#,$,%... style
                cv01 = true;
                # a style
                cv03 = true;
                # @ style
                cv04 = true;
                # == ligatures
                ss01 = true;
                # [TODO] pills
                ss02 = false;
                # <= ligatures
                ss04 = true;
                # {{ }} ligatures
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
                  <string>${font}</string>
                </test>
                <edit name="fontfeatures" mode="append">
                  ${lib.concatMapAttrsStringSep "\n" (
                    name: value: "<string>${name} ${if value then "on" else "off"}</string>"
                  ) features}
                  <!-- @ style -->
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
