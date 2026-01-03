{
  stdenvNoCC,
  lib,
  fetchurl,
  flavours,
}:
let
  lightImage = fetchurl {
    url = "https://basicappleguy.com/s/Rancho_Cucamonga_Tree_16.png";
    hash = "sha256-nzmZzBVbCjd+3BaQf7kyn1ZR+1pNDDTsr9gy+SAK5nM=";
  };
  darkImage = fetchurl {
    url = "https://basicappleguy.com/s/RanchoNight_16_Tree.png";
    hash = "sha256-30IwdsyBkT0TIFa/NfW5yL+UmrRvcrweYGfGn5Gw69M=";
  };
  name = "Rancho";
  bgProps = ''
    <?xml version="1.0"?>
    <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
    <wallpapers>
      <wallpaper deleted="false">
        <name>${name}</name>
        <filename>@out@/share/backgrounds/light-dark/${name}/${name}-l.png</filename>
        <filename-dark>@out@/share/backgrounds/light-dark/${name}/${name}-d.png</filename-dark>
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

    mkdir -p $out/share/backgrounds/light-dark/${name}
    mkdir -p $out/share/gnome-background-properties
    cp ${lightImage} $out/share/backgrounds/light-dark/${name}/${name}-l.png
    cp ${darkImage} $out/share/backgrounds/light-dark/${name}/${name}-d.png

    COLORS="$(flavours generate light $out/share/backgrounds/light-dark/${name}/${name}-l.png --name delete --slug delete --author delete --stdout | grep -v delete | awk '{ print $2 }' | sed '/^$/d; s/"//g; s/^/#/')"

    export primary_color=$(echo "$COLORS" | sed '1q;d')
    export secondary_color=$(echo "$COLORS" | sed '2q;d')

    echo "${lib.escapeShellArg bgProps}" > $out/share/gnome-background-properties/${name}.xml
    substituteAllInPlace $out/share/gnome-background-properties/${name}.xml

    runHook postInstall

  '';
  passthru = {
    dconfSettings = {
      "org/gnome/desktop/background" = {
        picture-uri = "${result.finalPackage}/share/backgrounds/light-dark/${name}/${name}-l.png";
        picture-uri-dark = "${result.finalPackage}/share/backgrounds/light-dark/${name}/${name}-d.png";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "${result.finalPackage}/share/backgrounds/light-dark/${name}/${name}-l.png";
      };
    };
  };
})
