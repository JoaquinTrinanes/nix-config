{
  xdg.configFile = {
    "wireplumber/wireplumber.conf.d/51-disable-microphone-output.conf".text = ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              media.class = "Audio/Sink"
              node.nick = "the t.bone MB7 Beta USB"
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
