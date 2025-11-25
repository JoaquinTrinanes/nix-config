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
      recursive
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
          fontConfig = {
            "FiraCode Nerd Font" = {
              features = {
                ss05 = true; # @ style
              };
            };
            monospace = {
              overrides = [
                {
                  tests.style = "Italic";
                  edits.family = "Recursive Mono Casual Static";
                }
                {
                  tests.style = "Bold Italic";
                  edits.family = "Recursive Mono Casual Static";
                }
              ];
            };
            Recursive = {
              variables = {
                MONO = 1;
                CASL = 1;
              };
              features = {
                aalt = true; # alternate l
                dlig = true; # enable ligatures
                ss12 = true; # alternate @
              };
            };
          };
          mkFontConfig =
            font:
            {
              features ? { },
              variables ? { },
              overrides ? [ ],
            }:
            ''
              ${lib.optionalString (features != { }) ''
                <match target="font">
                  <test name="family" compare="eq" ignore-blanks="true">
                    <string>${lib.escapeXML font}</string>
                  </test>
                  <edit name="fontfeatures" mode="append">
                    ${lib.concatMapAttrsStringSep "\n" (
                      name: value:
                      "<string>${lib.escapeXML name} ${
                        if lib.isBool value then (if value then "on" else "off") else (toString value)
                      }</string>"
                    ) features}
                  </edit>
                  </match>
              ''}
              ${lib.optionalString (variables != { }) ''
                <match target="font">
                  <test name="family" compare="eq" ignore-blanks="true">
                    <string>${lib.escapeXML font}</string>
                  </test>
                  <edit name="fontvariations" mode="append">
                    ${lib.concatMapAttrsStringSep "\n" (
                      name: value: "<string>${lib.escapeXML name}=${lib.escapeXML (toString value)}</string>"
                    ) variables}
                  </edit>
                </match>
              ''}
              ${lib.concatMapStringsSep "\n" (
                {
                  tests ? { },
                  edits ? { },
                }:
                ''
                  <match>
                    <test name="family" qual="any">
                      <string>${lib.escapeXML font}</string>
                    </test>
                    ${lib.concatMapAttrsStringSep "\n" (name: value: ''
                      <test name="${lib.escapeXML name}" qual="any">
                        <string>${lib.escapeXML value}</string>
                      </test>
                    '') tests}
                    ${lib.concatMapAttrsStringSep "\n" (name: value: ''
                      <edit name="${lib.escapeXML name}" mode="assign" binding="strong">
                        <string>${lib.escapeXML value}</string>
                      </edit>
                    '') edits}
                  </match>
                ''
              ) overrides}
            '';
        in
        ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            ${lib.concatMapAttrsStringSep "\n" mkFontConfig fontConfig}
          </fontconfig>
        '';
    };

    nixpkgs.config.joypixels.acceptLicense = true;
  };
}
