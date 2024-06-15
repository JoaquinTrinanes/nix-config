{
  xdg.configFile = {
    "wireplumber/wireplumber.conf.d/51-disable-microphone-output.conf".text = ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              node.name = "alsa_output.usb-the_t.bone_MB7_Beta_USB_the_t.bone_MB7_Beta_USB-00.analog-stereo"
            }
          ],
          actions = {
            update-props = {
              node.disabled = true
            }
          }
        }
      ]
    '';
  };
}
