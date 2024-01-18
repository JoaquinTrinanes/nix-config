{
  stdenv,
  lib,
  fetchurl,
  symlinkJoin,
  flavours,
  fetchFromGitHub,
}: let
  mkLightDarkWallpaper = name: {
    light,
    dark,
  }: let
    parsedName = lib.replaceStrings [" "] ["-"] name;
    bgProps = ''
      <?xml version=\"1.0\"?>
      <!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">
      <wallpapers>
        <wallpaper deleted=\"false\">
          <name>${name}</name>
          <filename>@out@/share/backgrounds/gnome/${parsedName}-l.png</filename>
          <filename-dark>@out@/share/backgrounds/gnome/${parsedName}-d.png</filename-dark>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>@primary_color@</pcolor>
          <scolor>@secondary_color@</scolor>
        </wallpaper>
      </wallpapers>
    '';
  in
    stdenv.mkDerivation {
      inherit name;

      unpackPhase = ":";

      nativeBuildInputs = [flavours];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/backgrounds/gnome
        mkdir -p $out/share/gnome-background-properties
        cp ${light} $out/share/backgrounds/gnome/${parsedName}-l.png
        cp ${dark} $out/share/backgrounds/gnome/${parsedName}-d.png

        COLORS="$(flavours generate light $out/share/backgrounds/gnome/${parsedName}-l.png --name delete --slug delete --author delete --stdout | grep -v delete | awk '{ print $2 }' | sed '/^$/d; s/"//g; s/^/#/')"

        export primary_color=$(echo "$COLORS" | sed '1q;d')
        export secondary_color=$(echo "$COLORS" | sed '2q;d')

        echo "${bgProps}" > $out/share/gnome-background-properties/${parsedName}.xml
        substituteAllInPlace $out/share/gnome-background-properties/${parsedName}.xml


        runHook postInstall

      '';
    };
  lightDarkWallpapers = lib.mapAttrsToList mkLightDarkWallpaper {
    Rancho = {
      light = fetchurl {
        url = "https://basicappleguy.com/s/Rancho_Cucamonga_Tree_16.png";
        hash = "sha256-nzmZzBVbCjd+3BaQf7kyn1ZR+1pNDDTsr9gy+SAK5nM=";
      };
      dark = fetchurl {
        url = "https://basicappleguy.com/s/RanchoNight_16_Tree.png";
        hash = "sha256-30IwdsyBkT0TIFa/NfW5yL+UmrRvcrweYGfGn5Gw69M=";
      };
    };
  };
  dynamicWallpapers =
    stdenv.mkDerivation
    {
      name = "Linux_Dynamic_Wallpapers";
      src = fetchFromGitHub {
        repo = "Linux_Dynamic_Wallpapers";
        owner = "saint-13";
        rev = "45128514ae51c6647ab3e427dda2de40c74a40e5";
        hash = "sha256-gmGtu28QfUP4zTfQm1WBAokQaZEoTJ2jL/Qk4BUNrhU=";
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/backgrounds/Dynamic_Wallpapers
        mkdir -p $out/share/gnome-background-properties

        substituteInPlace Dynamic_Wallpapers/*.xml xml/*.xml --replace /usr $out
        cp -r Dynamic_Wallpapers/* $out/share/backgrounds/Dynamic_Wallpapers
        cp xml/* $out/share/gnome-background-properties

        runHook postInstall
      '';
    };
in
  symlinkJoin {
    name = "dynamic-gnome-wallpapers";
    paths =
      lightDarkWallpapers
      ++ [dynamicWallpapers];
  }
