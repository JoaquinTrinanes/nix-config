{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.firefox;
  inherit (lib) mkDefault;
  mkPreference = name: value: {
    Value = value;
    Status = mkDefault cfg.preferencesStatus;
  };
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
in {
  programs.firefox = {
    enable = mkDefault true;
    # package = mkDefault pkgs.firefox-devedition;
    nativeMessagingHosts.packages = builtins.attrValues {inherit (pkgs) tridactyl-native;};
    preferencesStatus = mkDefault "locked";
    policies = {
      ExtensionSettings =
        (lib.genAttrs [
          "addon@darkreader.org"
          "uBlock0@raymondhill.net"
          "CanvasBlocker@kkapsner.de"
          "firefox-enpass@enpass.io"
          # "tridactyl.vim.betas@cmcaine.co.uk"
        ] (name: mkExtension {inherit name;}))
        // {
          "tridactyl.vim.betas@cmcaine.co.uk" = mkExtension {
            name = "tridactyl.vim.betas@cmcaine.co.uk";
            install_url = "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi";
          };
        };
      Preferences = lib.mapAttrs mkPreference {
        "browser.aboutConfig.showWarning" = false;
        "browser.translations.neverTranslateLanguages" = lib.concatStringsSep "," ["en" "es" "gl"];
        "browser.display.use_system_colors" = true;
        "browser.topsites.contile.cachedTiles" = "";
        "accessibility.typeaheadfind.enablesound" = false;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0";
        "general.platform.override" = "Win32";
        "general.autoScroll" = true; # enable middle click scroll
        "datareporting.healthreport.uploadEnabled" = false;

        # while recommended for privacy, this breaks p2p (google meet for example)
        "media.peerconnection.ice.default_address_only" = false;
        "media.peerconnection.enabled" = true;

        # extracted from https://github.com/pyllyukko/user.js/blob/master/user.js
        "app.shield.optoutstudies.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "privacy.donottrackheader.enabled" = true;
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
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
      };
    };
  };
}
