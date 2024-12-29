{
  stdenvNoCC,
  lib,
  fetchurl,
  symlinkJoin,
  flavours,
  fetchFromGitHub,
  wallpaperNames ? [ ],
  dynamicWallpaperHash ? "",
  withDynamic ? true,
}:
let
  mkLightDarkWallpaper =
    name:
    { light, dark }:
    let
      parsedName = lib.replaceStrings [ " " ] [ "-" ] name;
      bgProps = ''
        <?xml version=\"1.0\"?>
        <!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">
        <wallpapers>
          <wallpaper deleted=\"false\">
            <name>${name}</name>
            <filename>@out@/share/backgrounds/light-dark/${parsedName}/${parsedName}-l.png</filename>
            <filename-dark>@out@/share/backgrounds/light-dark/${parsedName}/${parsedName}-d.png</filename-dark>
            <options>zoom</options>
            <shade_type>solid</shade_type>
            <pcolor>@primary_color@</pcolor>
            <scolor>@secondary_color@</scolor>
          </wallpaper>
        </wallpapers>
      '';
    in
    stdenvNoCC.mkDerivation (result: {
      inherit name;

      strictDeps = true;

      unpackPhase = ":";

      nativeBuildInputs = [ flavours ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/backgrounds/light-dark/${parsedName}
        mkdir -p $out/share/gnome-background-properties
        cp ${light.image} $out/share/backgrounds/light-dark/${parsedName}/${parsedName}-l.png
        cp ${dark.image} $out/share/backgrounds/light-dark/${parsedName}/${parsedName}-d.png

        COLORS="$(flavours generate light $out/share/backgrounds/light-dark/${parsedName}/${parsedName}-l.png --name delete --slug delete --author delete --stdout | grep -v delete | awk '{ print $2 }' | sed '/^$/d; s/"//g; s/^/#/')"

        export primary_color=$(echo "$COLORS" | sed '1q;d')
        export secondary_color=$(echo "$COLORS" | sed '2q;d')

        echo "${bgProps}" > $out/share/gnome-background-properties/${parsedName}.xml
        substituteAllInPlace $out/share/gnome-background-properties/${parsedName}.xml

        runHook postInstall

      '';
      passthru = {
        dconfSettings = {
          "org/gnome/desktop/background" = {
            picture-uri = "${result.finalPackage}/share/backgrounds/light-dark/${parsedName}/${parsedName}-l.png";
            picture-uri-dark = "${result.finalPackage}/share/backgrounds/light-dark/${parsedName}/${parsedName}-d.png";
          };
          "org/gnome/desktop/screensaver" = {
            picture-uri = "${result.finalPackage}/share/backgrounds/light-dark/${parsedName}/${parsedName}-l.png";
          };
        };
      };
    });
  lightDarkWallpapers = lib.mapAttrs mkLightDarkWallpaper {
    Rancho = {
      light = {
        image = fetchurl {
          url = "https://basicappleguy.com/s/Rancho_Cucamonga_Tree_16.png";
          hash = "sha256-nzmZzBVbCjd+3BaQf7kyn1ZR+1pNDDTsr9gy+SAK5nM=";
        };
      };
      dark = {
        image = fetchurl {
          url = "https://basicappleguy.com/s/RanchoNight_16_Tree.png";
          hash = "sha256-30IwdsyBkT0TIFa/NfW5yL+UmrRvcrweYGfGn5Gw69M=";
        };
      };
    };
  };
  dynamic-wallpapers = stdenvNoCC.mkDerivation {
    strictDeps = true;
    name = "Linux_Dynamic_Wallpapers";
    src = fetchFromGitHub {
      repo = "Linux_Dynamic_Wallpapers";
      owner = "saint-13";
      rev = "45128514ae51c6647ab3e427dda2de40c74a40e5";
      hash =
        if (wallpaperNames == [ ]) then
          "sha256-gmGtu28QfUP4zTfQm1WBAokQaZEoTJ2jL/Qk4BUNrhU="
        else
          dynamicWallpaperHash;
      sparseCheckout =
        lib.optionals (wallpaperNames == [ ]) [
          "Dynamic_Wallpapers"
          "xml"
        ]
        ++ lib.optionals (wallpaperNames != [ ]) (
          lib.flatten (
            map (w: [
              "Dynamic_Wallpapers/${w}"
              "Dynamic_Wallpapers/${w}.xml"
              "xml/${w}.xml"
            ]) wallpaperNames
          )
        );
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/backgrounds
      mkdir -p $out/share/gnome-background-properties

      substituteInPlace Dynamic_Wallpapers/*.xml xml/*.xml --replace-fail /usr $out
      ${lib.optionalString (wallpaperNames == [ ]) ''
        cp -r Dynamic_Wallpapers $out/share/backgrounds/
        cp xml/* $out/share/gnome-background-properties
      ''}
      ${lib.optionalString (wallpaperNames != [ ]) ''
        mkdir $out/share/backgrounds/Dynamic_Wallpapers
        cp -r Dynamic_Wallpapers/{${lib.concatStringsSep "," wallpaperNames}} $out/share/backgrounds/Dynamic_Wallpapers
        cp xml/{${lib.concatStringsSep "," wallpaperNames}}.xml $out/share/gnome-background-properties
      ''}

      runHook postInstall
    '';
  };
in
symlinkJoin {
  name = "dynamic-gnome-wallpapers";
  passthru = lightDarkWallpapers // {
    inherit dynamic-wallpapers;
  };
  paths = builtins.attrValues lightDarkWallpapers ++ lib.optionals withDynamic [ dynamic-wallpapers ];
}
