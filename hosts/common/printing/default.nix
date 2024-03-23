{ pkgs, lib, ... }:
{
  imports = [
    {
      # users.users."cups".extraGroups = ["lp"];
      # services.udev.extraRules = let
      #   #   # originalHotplugScript = "${pkgs.foo2zjs}/etc/hotplug/usb/hplj1000";
      #   # scriptText = "vasio";
      #   scriptText = lib.replaceStrings ["/usr/lib/cups/backend/usb"] ["${pkgs.cups}/lib/cups/backend/usb"] (builtins.readFile "${pkgs.foo2zjs}/etc/hotplug/usb/hplj1018");
      #   #   printerModels = [
      #   #     # "hplj1000"
      #   #     "hplj1005"
      #   #     "hplj1018"
      #   #     "hplj1020"
      #   #     "hpljP1005"
      #   #     "hpljP1006"
      #   #     "hpljP1007"
      #   #     "hpljP1008"
      #   #     "hpljP1505"
      #   #   ];
      #   printerModels = ["hplj1018"];
      #   #   # printerModels = builtins.map builtins.baseNameOf (lib.filesystem.listFilesRecursive "${pkgs.foo2zjs}/etc/hotplug/usb");
      #   mkScript = name: "${pkgs.writeShellScriptBin name scriptText}/bin/${name}";
      #   mkPrinterUdevRule = model: let
      #     number = lib.removePrefix "hplj" model;
      #   in ''
      #     #Own udev rule for HP Laserjet ${number}
      #     ATTRS{product}=="hp LaserJet ${number}", NAME="usb/%k", \
      #     SYMLINK+="${model}-%n", MODE="0666", ENV{FOO2ZJS_DATADIR}="${pkgs.foo2zjs}/share" RUN+="${mkScript model}"
      #   '';
      # in ''
      #   ACTION!="add", GOTO="foo2zjs_fw_end"
      #   SUBSYSTEMS!="usb", GOTO="foo2zjs_fw_end"
      #   ATTRS{idVendor}=="03f0", GOTO="foo2zjs_fw_end"
      #   ${lib.concatLines (builtins.map mkPrinterUdevRule printerModels)}
      #   LABEL="foo2zjs_fw_end"
      # '';
    }
  ];
  # services.udev.extraRules = ''
  #   # Arch udev rules
  #   ACTION!="add", GOTO="foo2zjs_fw_end"
  #   SUBSYSTEM!="usb", GOTO="foo2zjs_fw_end"
  #   ENV{DEVTYPE}!="usb_device", GOTO="foo2zjs_fw_end"
  #
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0517", ENV{FOO2ZJS_FW_MODEL}="1000"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="1317", ENV{FOO2ZJS_FW_MODEL}="1005"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="4117", ENV{FOO2ZJS_FW_MODEL}="1018"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="2b17", ENV{FOO2ZJS_FW_MODEL}="1020"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="3d17", ENV{FOO2ZJS_FW_MODEL}="P1005"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="3e17", ENV{FOO2ZJS_FW_MODEL}="P1006"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="4817", ENV{FOO2ZJS_FW_MODEL}="P1007"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="4917", ENV{FOO2ZJS_FW_MODEL}="P1008"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="3f17", ENV{FOO2ZJS_FW_MODEL}="P1505"
  #   ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="4017", ENV{FOO2ZJS_FW_MODEL}="P1505n"
  #   ENV{FOO2ZJS_FW_MODEL}=="", GOTO="foo2zjs_fw_end"
  #
  # #   RUN+="/usr/bin/foo2zjs-loadfw %S%p"
  #   RUN+="${foo2zjs}/bin/foo2zjs-loadfw %S%p"
  #
  #   LABEL="foo2zjs_fw_end"
  # '';
  services.printing = {
    enable = true;
    logLevel = "debug";
    drivers = with pkgs; [
      # gutenprint
      hplipWithPlugin
      # foo2zjs
      # cups-filters
      # foomatic-filters
      # poppler_utils
    ];
    # cups-pdf.enable = true;
    # extraConf = ''
    #   SetEnv PATH /var/lib/cups/path/lib/cups/filter:/var/lib/cups/path/bin
    # '';
    # logLevel = "debug";
  };
  # environment.systemPackages = with pkgs; [ghostscript gutenprint cups-filters];
}
