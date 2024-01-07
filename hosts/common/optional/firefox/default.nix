{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.firefox;
  inherit (lib) mkDefault;
  mkExtensionUrl = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
  mkExtension = {
    name,
    installation_mode ? "normal_installed", # normal_installed, force_installed, blocked, allowed
    install_url ? (mkExtensionUrl name),
    install_sources ? [],
    allowed_types ? ["extension" "theme" "dictionary" "locale"],
    blocked_install_message ? null,
    restricted_domains ? [],
    updates_disabled ? false,
    default_area ? "menupanel", # menupanel, navbar
  }: {inherit name installation_mode install_url install_sources allowed_types blocked_install_message restricted_domains updates_disabled default_area;};
  mkAutoconfig = let
    statusFunctionName = {
      locked = "lockPref";
      default = "defaultPref";
      user = "pref";
      clear = "clearPref";
    };
  in
    name: value: {status ? cfg.preferencesStatus}: ''
      ${statusFunctionName.${status}}("${name}", ${builtins.toJSON value});
    '';
in {
  programs.firefox = {
    enable = mkDefault true;
    nativeMessagingHosts.packages = builtins.attrValues {inherit (pkgs) tridactyl-native;};
    preferencesStatus = mkDefault "locked";
    # Preferences not allowed in policies
    autoConfig = lib.concatLines (lib.mapAttrsToList (name: value: mkAutoconfig name value {}) {
      "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0";
      "general.platform.override" = "Win32";

      "app.normandy.enabled" = false;
      "app.normandy.api_url" = "";
      "app.shield.optoutstudies.enabled" = false;
      "breakpad.reportURL" = "";
      "datareporting.healthreport.uploadEnabled" = false;
      "devtools.screenshot.audio.enabled" = false;
      "privacy.donottrackheader.enabled" = true;

      "toolkit.coverage.endpoint.base" = "";
      "toolkit.coverage.opt-out" = true;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.server" = "data:,";
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
    });
    preferences = {
      "browser.aboutConfig.showWarning" = false;
      "browser.translations.neverTranslateLanguages" = lib.concatStringsSep "," ["en" "es" "gl"];
      "browser.display.use_system_colors" = true;
      "accessibility.typeaheadfind.enablesound" = false;
      "extensions.activeThemeID" = "default-theme@mozilla.org"; # responsive to light and dark mode changes, and not always the default
      "general.autoScroll" = true; # enable middle click scroll

      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      # avoid random sounds
      "media.autoplay.default" = 1; # 0 = Allowed, 1 = Blocked, 2 = Prompt
      "media.autoplay.allow-muted" = false;
      "media.block-autoplay-until-in-foreground" = true;

      # privacy settings
      "browser.topsites.contile.cachedTiles" = "";

      # while recommended for privacy, this breaks p2p (google meet for example)
      "media.peerconnection.ice.default_address_only" = false;
      "media.peerconnection.enabled" = true;

      # extracted from https://github.com/pyllyukko/user.js/blob/master/user.js
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      "network.trr.mode" = 2; # 0 = off (default), 1 = <reserved>, 2 = first, 3 = only, 4 = <reserved>, 5 = off by choice
      "network.dns.echconfig.enabled" = true;
      "network.dns.http3_echconfig.enabled" = true;
      "browser.safebrowsing.malware.enabled" = false;
      "browser.safebrowsing.phishing.enabled" = false;
      "browser.safebrowsing.downloads.enabled" = false;
      "browser.startup.page" = 3; # 0 = blank, 1 = home, 2 = last visited page, 3 = resume previous session
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.default.sites" = "";
      "extensions.getAddons.showPane" = false;
      "extensions.htmlaboutaddons.recommendations.enabled" = true;
      "browser.discovery.enabled" = false;
      "browser.shopping.experience2023.enabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "browser.ping-centre.telemetry" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.tabs.crashReporting.sendReport" = false;
    };
    policies = {
      ExtensionSettings =
        (lib.genAttrs [
          "addon@darkreader.org"
          "uBlock0@raymondhill.net"
          "CanvasBlocker@kkapsner.de"
          "firefox-enpass@enpass.io"
          "vpn@proton.ch"
        ] (name: mkExtension {inherit name;}))
        // {
          "tridactyl.vim.betas@cmcaine.co.uk" = mkExtension {
            name = "tridactyl.vim.betas@cmcaine.co.uk";
            install_url = "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi";
          };
        };
      SearchEngines = {
        Remove = ["amazon@search.mozilla.org" "bing@search.mozilla.org"];
      };
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      OfferToSaveLoginsDefault = false;
      OverridePostUpdatePage = "";
      OverrideFirstRunPage = "";
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
      };
    };
  };
}
