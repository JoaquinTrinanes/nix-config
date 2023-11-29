{
  cups,
  fetchzip,
  lib,
  stdenv,
  fetchurl,
  foomatic-filters,
  bc,
  ghostscript,
  systemd,
  vim,
  time,
  symlinkJoin,
}: let
  getLsFirmware = printer: sha256:
    stdenv.mkDerivation {
      name = "foo2zjs-${printer}-firmware.img";
      src = fetchzip {
        name = "${printer}.tar.gz";
        url = "http://foo2zjs.linkevich.net/foo2zjs/firmware/${printer}.tar.gz";
        inherit sha256;
      };

      unpackPhase = '':'';

      installPhase = ''
        # runHook preInstall
        mkdir -p $out/share/foo2zjs/firmware
        cp $src $out/share/foo2zjs/firmware/${printer}.dl
        # runHook postInstall
      '';
    };
  firmwares = symlinkJoin {
    name = "sihp1XXX";
    paths = [(getLsFirmware "sihp1018" "sha256:167n4cw4vrv95brskzr4flmp3fd89ah5vg9crzlbkx11b31vcp6p")];
  };
in
  stdenv.mkDerivation {
    pname = "foo2zjs";
    version = "custom";

    src = fetchurl {
      url = "https://foo2zjs.linkevich.net/foo2zjs/foo2zjs.tar.gz";
      sha256 = "sha256:1v28d0fymxj5mhmlhhcm650v0dsg9qypzdlakqb8c567a3b74z5d";
    };

    buildInputs = [foomatic-filters bc ghostscript systemd vim];

    patches = [
      ./no-hardcode-fw.diff
      # Support HBPL1 printers. Updated patch based on
      # https://www.dechifro.org/hbpl/
      ./hbpl1.patch
      # Fix "Unimplemented paper code" error for hbpl1 printers
      # https://github.com/mikerr/foo2zjs/pull/2
      ./papercode-format-fix.patch
      # Fix AirPrint color printing for Dell 1250c
      # See https://github.com/OpenPrinting/cups/issues/272
      ./dell1250c-color-fix.patch
    ];

    makeFlags = [
      "PREFIX=$(out)"
      "APPL=$(out)/share/applications"
      "PIXMAPS=$(out)/share/pixmaps"
      "UDEVBIN=$(out)/bin"
      "UDEVDIR=$(out)/etc/udev/rules.d"
      "UDEVD=${systemd}/sbin/udevd"
      "LIBUDEVDIR=$(out)/lib/udev/rules.d"
      "USBDIR=$(out)/etc/hotplug/usb"
      "FOODB=$(out)/share/foomatic/db/source"
      "MODEL=$(out)/share/cups/model"
    ];

    installFlags = ["install-hotplug"];

    postPatch = ''
      touch all-test
      sed -e "/BASENAME=/iPATH=$out/bin:$PATH" -i *-wrapper *-wrapper.in
      sed -e "s@PREFIX=/usr@PREFIX=$out@" -i *-wrapper{,.in}
      sed -e "s@/usr/share@$out/share@" -i hplj10xx_gui.tcl
      sed -e "s@\[.*-x.*/usr/bin/logger.*\]@type logger >/dev/null 2>\&1@" -i *wrapper{,.in}
      sed -e '/install-usermap/d' -i Makefile
      sed -e "s@/etc/hotplug/usb@$out&@" -i *rules*
      sed -e "s@/usr@$out@g" -i hplj1020.desktop
      sed -e "/PRINTERID=/s@=.*@=$out/bin/usb_printerid@" -i hplj1000

      # for some reason KERNEL is not set to lpX on my laptop, should work anyway
      sed -e "s@KERNEL==\"lp\\*\", @@" -i *rules*

      # remove hardcoded USB_BACKEND
      sed -e "/USB_BACKEND=/s@=.*@=${cups}/lib/cups/backend/usb@" -i hplj1000

      # non-existing FOO2ZJS_DATADIR
      sed -e "s@^\s*fw=\".*\"@fw=\"$out/share/\$DRIVER/firmware/sihp\$FWMODEL.dl\"@" -i hplj1000

      # NAME=... is not valid for systemd udev unless device is a network device
      sed -e 's@NAME="usb/%k"@SYMLINK+="usb/lp0", GROUP="lp"@g' -i *rules*

      # remove bg job
      sed -e 's@&@@g' -i hplj1000
    '';

    nativeCheckInputs = [time];
    doCheck = false; # fails to find its own binary. Also says "Tests will pass only if you are using ghostscript-8.71-16.fc14".

    preInstall = ''
      mkdir -pv $out/{etc/udev/rules.d,lib/udev/rules.d,etc/hotplug/usb}
      mkdir -pv $out/share/foomatic/db/source/{opt,printer,driver}
      mkdir -pv $out/share/cups/model
      mkdir -pv $out/share/{applications,pixmaps,foo2zjs/firmware}

      mkdir -pv "$out/bin"
      cp -v getweb arm2hpdl "$out/bin"

      ln -s ${firmwares}/share/foo2zjs/firmware/* $out/share/foo2zjs/firmware/
    '';
    meta = with lib; {
      description = "ZjStream printer drivers";
      platforms = platforms.linux;
      license = licenses.gpl2Plus;
    };
  }
