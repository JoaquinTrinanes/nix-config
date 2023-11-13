{
  lib,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = lib.mkDefault true;
    package = pkgs.firefox-devedition;
    profiles = let
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.translations.neverTranslateLanguages" = lib.concatStringsSep "," ["es" "gl"];
        "browser.display.use_system_colors" = true;
        "browser.topsites.contile.cachedTiles" = [];
        "accessibility.typeaheadfind.enablesound" = false;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0";
        "general.platform.override" = "Win32";
        "media.peerconnection.ice.default_address_only" = true;
        "media.peerconnection.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "privacy.donottrackheader.enabled" = true;
        "network.trr.mode" = 2;
        "network.dns.echconfig.enabled" = true;
        "network.dns.http3_echconfig.enabled" = true;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.startup.page" = 3; # 0=blank, 1=home, 2=last visited page, 3=resume previous session
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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
      ];
    in
      lib.mapAttrs (_: profile: profile // {inherit settings extensions;}) {
        "dev-edition-default" = {
          id = 0;
          inherit settings;
          isDefault = true;
        };
        "default" = {
          id = 1;
          inherit settings;
        };
      };
  };
}
