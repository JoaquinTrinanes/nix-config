{ lib, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "noiseReduction";
    extraPresets = {
      noiseReduction = {
        input = {
          blocklist = [ ];
          plugins_order = [ "rnnoise#0" ];
          "rnnoise#0" = {
            bypass = false;
            enable-vad = true;
            input-gain = 0.0;
            model-name = "";
            output-gain = 0.0;
            release = 20.0;
            vad-thres = 20.0;
            wet = 0.0;
          };
        };
      };
      WH-1000XM4 =
        let
          bands = builtins.listToAttrs (
            lib.lists.imap0
              (
                i: band:
                lib.nameValuePair "band${toString i}" {
                  inherit (band) frequency gain;
                  mode = "RLC (BT)";
                  mute = false;
                  q = 4.36;
                  slope = "x1";
                  solo = false;
                  width = 4;
                  type = "Bell";
                }
              )
              [
                {
                  frequency = 25;
                  gain = 0.7;
                }
                {
                  frequency = 38;
                  gain = 1;
                }
                {
                  frequency = 59;
                  gain = -0.4;
                }
                {
                  frequency = 91;
                  gain = -2.8;
                }
                {
                  frequency = 140;
                  gain = -4.4;
                }
                {
                  frequency = 220;
                  gain = -2.9;
                }
                {
                  frequency = 330;
                  gain = -0.5;
                }
                {
                  frequency = 510;
                  gain = 0.2;
                }
                {
                  frequency = 780;
                  gain = 0;
                }
                {
                  frequency = 1200;
                  gain = 0.7;
                }
                {
                  frequency = 1900;
                  gain = 1.8;
                }
                {
                  frequency = 2900;
                  gain = -0.1;
                }
                {
                  frequency = 4400;
                  gain = 0.3;
                }
                {
                  frequency = 6800;
                  gain = 3.9;
                }
                {
                  frequency = 10500;
                  gain = 0.8;
                }
              ]
          );
        in
        {
          output = {
            blocklist = [ ];
            "equalizer#0" = {
              balance = 0;
              bypass = false;
              input-gain = 0;
              left = bands;
              mode = "IIR";
              num-bands = 16;
              output-gain = 0;
              pitch-left = 0;
              pitch-right = 0;
              right = bands;
              split-channels = false;
            };
            plugins_order = [ "equalizer#0" ];
          };
        };
    };
  };

  # Fix default preset not being loaded
  # nix-community/home-manager/issues/5185
  # systemd.user.services.easyeffects.Service = {
  #   ExecStart = lib.mkForce "${config.services.easyeffects.package}/bin/easyeffects --gapplication-service";
  #   ExecStartPost = lib.mkIf (config.services.easyeffects.preset != "") [
  #     "${config.services.easyeffects.package}/bin/easyeffects --load-preset ${config.services.easyeffects.preset}"
  #   ];
  # };

  # dconf.settings."com/github/wwmm/easyeffects" = {
  #   process-all-inputs = true;
  # };

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
