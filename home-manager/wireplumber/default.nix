_: {
  xdg.configFile = {
    # "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = '''';
    "wireplumber/main.lua.d/51-disable-microphone-output.lua".text = ''
      rule = {
        matches = {
          {
            { "node.name", "equals", "alsa_output.usb-the_t.bone_MB7_Beta_USB_the_t.bone_MB7_Beta_USB-00.analog-stereo" },
          },
        },
        apply_properties = {
          ["device.disabled"] = true,
        },
      }

      table.insert(alsa_monitor.rules,rule)
    '';
  };
}
