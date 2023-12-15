# From https://github.com/haztecaso/nixos-configs/blob/4fd3776c1f5c043b008dc3e68ff6f0415013cdf4/overlay/autofirma.nix
{
  stdenv,
  lib,
  fetchurl,
  makeDesktopItem,
  unzip,
  dpkg,
  bash,
  jre8,
}:
stdenv.mkDerivation rec {
  pname = "autofirma";
  version = "1.6.5";

  src = fetchurl {
    url = "https://estaticos.redsara.es/comunes/autofirma/${builtins.replaceStrings ["."] ["/"] version}/AutoFirma_Linux.zip";
    hash =
      {
        "1.7.1" = "sha256-bNYaWciKlJvdO4GwYOrIDN2mcQWtf3UpoqHu2RbotmA=";
        "1.6.5" = "sha256-sjgC/Zn397YKsX5wCbMf5WftGu1nT7EQT3C5AahG2v8=";
      }
      .${version}
      or "";
  };

  desktopItem = makeDesktopItem {
    name = "AutoFirma";
    desktopName = "AutoFirma";
    exec = "AutoFirma %u";
    icon = "AutoFirma";
    # mimeType = "x-scheme-handler/afirma;";
    categories = ["Office"];
  };

  buildInputs = [bash jre8];
  nativeBuildInputs = [unzip dpkg jre8];

  unpackPhase = ''
    unzip $src AutoFirma_${builtins.replaceStrings ["."] ["_"] version}.deb
    dpkg-deb -x AutoFirma_${builtins.replaceStrings ["."] ["_"] version}.deb .
  '';

  buildPhase = ''
    ${jre8}/bin/java -jar usr/lib/AutoFirma/AutoFirmaConfigurador.jar
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 usr/lib/AutoFirma/AutoFirma.jar $out/share/AutoFirma/AutoFirma.jar
    install -Dm644 usr/lib/AutoFirma/AutoFirmaConfigurador.jar $out/share/AutoFirma/AutoFirmaConfigurador.jar
    install -Dm644 usr/share/AutoFirma/AutoFirma.svg $out/share/AutoFirma/AutoFirma.svg
    install -Dm644 usr/lib/AutoFirma/AutoFirma.png $out/share/pixmaps/AutoFirma.png

    install -d $out/bin
    cat > $out/bin/AutoFirma <<EOF
    #!${bash}/bin/sh
    ${jre8}/bin/java -jar $out/share/AutoFirma/AutoFirma.jar \''$*
    EOF
    chmod +x $out/bin/AutoFirma

    install -Dm644 usr/lib/AutoFirma/AutoFirma_ROOT.cer $out/share/ca-certificates/trust-source/anchors/AutoFirma_ROOT.cer

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Spanish Government digital signature tool";
    homepage = "https://firmaelectronica.gob.es/Home/Ciudadanos/Aplicaciones-Firma.html";
    license = with licenses; [gpl2Only eupl11];
    platforms = platforms.linux;
  };
}
