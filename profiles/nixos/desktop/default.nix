{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.desktop;
in
{
  imports = [
    ./gnome.nix
    ./wayland.nix
  ];

  options.profiles.desktop = {
    enable = lib.mkEnableOption "desktop profile";
  };

  config = lib.mkIf cfg.enable {
    xdg.mime.enable = lib.mkDefault true;

    profiles.firefox.enable = lib.mkDefault true;
    profiles.desktop.gnome.enable = lib.mkDefault true;
    profiles.fonts.enable = lib.mkDefault true;
    profiles.audio.enable = lib.mkDefault true;
    profiles.autofirma.enable = lib.mkDefault true;

    programs.chromium = {
      enable = true;
      extraOpts = {
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        BraveAIChatEnabled = false;
        BraveNewsDisabled = true;
        BraveTalkDisabled = true;
        BraveP3AEnabled = false;
        BraveStatsPingEnabled = false;

        ForcedLanguages = [ "en-US" ];
        HomepageIsNewTabPage = true;
        MetricsReportingEnabled = false;
        PasswordManagerEnabled = false;
        PaymentMethodQueryEnabled = false;
        SSLErrorOverrideAllowed = true;

        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderKeyword = ":d";
        DefaultSearchProviderName = "DuckDuckGo";

        ExtensionSettings =
          lib.mapAttrs
            (
              _: ext:
              {
                installation_mode = "force_installed";
                update_url = "https://clients2.google.com/service/update2/crx";
              }
              // ext
            )
            {
              "dbepggeogbaibhgnhhndojpepiihcmeb" = { }; # vimium
              "eimadpbcbfnmbkopoojfekhnkhdbieeh" = { }; # dark reader
              "jplgfhpmjnbigmhklmmbgecoobifkmpa" = { }; # proton vpn
              "ghmbeldphafepmbegfdlkpapadhbakde" = {
                # proton pass
                toolbar_pin = "force_pinned";
              };
              "lioaeidejmlpffbndjhaameocfldlhin" = { }; # redirector
              "enamippconapkdmgfgjchkhakpfinmaj" = { }; # dearrow
              "mnjggcdmjocbbbhaepdhchncahnbgone" = { }; # sponsorblock
            };
        RestoreOnStartup =
          {
            restore = 1;
            urlList = 4;
            newTab = 5;
            urlListAndRestore = 6;
          }
          ."restore";
      };
    };

    time.timeZone = lib.mkDefault "Europe/Madrid";

    services.libinput.touchpad = lib.mkDefault {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
    };

    services.displayManager.gdm.enable = lib.mkDefault true;

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        vesktop
        qbittorrent
        telegram-desktop
        vlc
        ;
    };
    programs.dconf = {
      enable = lib.mkDefault true;
      profiles.gdm.databases = [
        {
          settings = {
            "org/gnome/desktop/peripherals/touchpad" = {
              tap-to-click = true;
            };
            "org/gnome/login-screen" = {
              logo = "";
            };
          };
        }
      ];
    };

    nix.daemonCPUSchedPolicy = lib.mkDefault "idle";

    xdg.portal.enable = lib.mkDefault true;
  };
}
