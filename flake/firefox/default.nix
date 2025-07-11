{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      firefoxConfig = {
        nativeMessagingHosts = builtins.attrValues { inherit (pkgs) tridactyl-native; };
        extraPolicies = {
          ExtensionSettings =
            let
              pinnedExtensions = [
                # "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" # violent monkey
                "78272b6fa58f4a1abaac99321d503a20@proton.me" # proton pass
                "CanvasBlocker@kkapsner.de"
                "addon@darkreader.org"
                "firefox-enpass@enpass.io"
                "smart-referer@meh.paranoid.pk"
                "uBlock0@raymondhill.net"
                "vpn@proton.ch"
              ];
              hiddenExtensions = [
                # Settings: block VP{8,9}. TODO: Check if still needed with 4K videos
                "{9a41dee2-b924-4161-a971-7fb35c053a4a}" # enhanced-h264ify.
                "idcac-pub@guus.ninja" # I still don't care about cookies
                "redirector@einaregilsson.com"
                "{b5501fd1-7084-45c5-9aa6-567c2fcf5dc6}" # Ruffle flash emulator
              ];
            in
            (lib.genAttrs hiddenExtensions (name: mkExtension { inherit name; }))
            // lib.genAttrs pinnedExtensions (
              name:
              mkExtension {
                inherit name;
                default_area = "navbar";
              }
            )
            // {
              "tridactyl.vim.betas@cmcaine.co.uk" = mkExtension {
                name = "tridactyl.vim.betas@cmcaine.co.uk";
                install_url = "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi";
              };
            };
          SearchEngines = {
            Default = "DuckDuckGo";
            Remove = map (s: "${s}@search.mozilla.org") [
              "amazon"
              "bing"
              "google"
            ];
          };
          DNSOverHTTPS = {
            Enabled = true;
            Fallback = false;
            Locked = false;
            ProviderURL = "https://dns.quad9.net/dns-query";
          };
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            # Fingerprinting = true;
            # Exceptions=[];
          };
          Homepage = {
            StartPage = "previous-session";
          };
          HttpsOnlyMode = "enabled";
          DisableAppUpdate = true;
          NoDefaultBookmarks = true;
          PostQuantumKeyAgreementEnabled = true;
          SearchBar = "unified";

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
        extraPrefs =

          lib.concatLines (
            lib.mapAttrsToList (name: value: mkAutoconfig name value { }) {
              "media.ffmpeg.vaapi.enabled" = true;
              "gfx.webrender.all" = true;

              # disable account icon (?)
              "identity.fxaccounts.toolbar.enabled" = false;

              "full-screen-api.transition-duration.enter" = "0 0";
              "full-screen-api.transition-duration.leave" = "0 0";
              "full-screen-api.warning.delay" = -1;
              "full-screen-api.warning.timeout" = 0;

              "security.ssl.treat_unsafe_negotiation_as_broken" = true;

              # Unhide the "add exception" button on the SSL error page, allowing users to directly accept a bad certificate
              "browser.xul.error_pages.expert_bad_cert" = true;

              "app.normandy.enabled" = false;
              "app.normandy.api_url" = "";
              "app.shield.optoutstudies.enabled" = false;
              "breakpad.reportURL" = "";
              "datareporting.healthreport.uploadEnabled" = false;
              "devtools.screenshot.audio.enabled" = false;
              # "privacy.resistFingerprinting" = true;
              "privacy.donottrackheader.enabled" = true;
              "privacy.globalprivacycontrol.enabled" = true;

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

              "privacy.trackingprotection.enabled" = true;

              "security.ssl3.deprecated.rsa_des_ede3_sha" = false;
              "security.ssl3.dhe_rsa_aes_128_sha" = false;
              "security.ssl3.dhe_rsa_aes_256_sha" = false;
              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              # "security.ssl3.ecdhe_ecdsa_aes_128_sha" = false;
              # "security.ssl3.ecdhe_ecdsa_aes_256_sha" = false;
              # "security.ssl3.ecdhe_rsa_aes_128_sha" = false;
              # "security.ssl3.ecdhe_rsa_aes_256_sha" = false;
              # "security.ssl3.rsa_aes_128_sha" = false;
              # "security.ssl3.rsa_aes_256_sha" = false;
              # "security.ssl3.rsa_aes_128_gcm_sha256" = false;
              # "security.ssl3.rsa_aes_256_gcm_sha384" = false;

              # 1 = only base system fonts
              # 2 = also fonts from optional language packs
              # 3 = also user-installed fonts
              # "layout.css.font-visibility.standard" = 1; # 3;
              # "layout.css.font-visibility.trackingprotection" = 3;
              # "layout.css.font-visibility.resistFingerprinting" = true;
              # "layout.css.font-visibility.private" = 1; # 3;

              # PREF: initial paint delay
              # How long FF will wait before rendering the page (in ms)
              # [NOTE] You may prefer using 250.
              # [NOTE] Dark Reader users may want to use 1000 [3].
              # [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1283302
              # [2] https://docs.google.com/document/d/1BvCoZzk2_rNZx3u9ESPoFjSADRI0zIPeJRXFLwWXx_4/edit#heading=h.28ki6m8dg30z
              # [3] https://old.reddit.com/r/firefox/comments/o0xl1q/reducing_cpu_usage_of_dark_reader_extension/
              # [4] https://reddit.com/r/browsers/s/wvNB7UVCpx
              "nglayout.initialpaint.delay" = 1000; # DEFAULT = 5;
              "nglayout.initialpaint.delay_in_oopif" = 5; # DEFAULT

              # Help url
              "app.support.baseURL" = "http://127.0.0.1/";
              "app.support.inputURL" = "http://127.0.0.1/";
              "app.feedback.baseURL" = "http://127.0.0.1/";
              "browser.uitour.url" = "http://127.0.0.1/";
              "browser.uitour.themeOrigin" = "http://127.0.0.1/";
              "plugins.update.url" = "http://127.0.0.1/";
              "browser.customizemode.tip0.learnMoreUrl" = "http://127.0.0.1/";

              # Disable "beacon" asynchronous HTTP transfers (used for analytics)
              # https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
              "beacon.enabled" = false;

              # Disable pinging URIs specified in HTML <a> ping= attributes
              # http://kb.mozillazine.org/Browser.send_pings
              "browser.send_pings" = false;

              # Disable gamepad API to prevent USB device enumeration
              # https://www.w3.org/TR/gamepad/
              # https://trac.torproject.org/projects/tor/ticket/13023
              "dom.gamepad.enabled" = false;

              "content.notify.interval" = 100000;
              "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsored" = false;
              "services.sync.prefs.sync.browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "social.enabled" = false;
              "social.remote-install.enabled" = false;
              "startup.homepage_welcome_url" = "";

              # Hide about:config warning
              "browser.aboutConfig.showWarning" = false;

              "browser.translations.neverTranslateLanguages" = lib.concatStringsSep "," [
                "en"
                "es"
                "gl"
              ];
              "browser.display.use_system_colors" = true;
              "extensions.activeThemeID" = "default-theme@mozilla.org"; # responsive to light and dark mode changes, and not always the default

              "general.autoScroll" = true; # enable middle click scroll
              "middlemouse.paste" = false;

              "browser.toolbars.bookmarks.visibility" = "newtab";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

              # Managed by policy
              # "dom.security.https_only_mode" = true;

              # prevent mouse middle click on new tab button to trigger searches or page loads
              "browser.tabs.searchclipboardfor.middleclick" = false;

              # Prevent EULA dialog to popup on first run
              "browser.EULA.override" = true;

              # Don't call home for blacklisting
              "extensions.blocklist.enabled" = false;

              # Disable homecalling
              "app.update.url" = "http://127.0.0.1/";

              # Enable containers
              "privacy.userContext.enabled" = true;
              "privacy.userContext.ui.enabled" = true;

              # force webrtc inside proxy when one is used
              "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;

              # forces dns query through the proxy when using one
              "network.proxy.socks_remote_dns" = true;

              # Don't download ads for the newtab page
              "browser.newtabpage.directory.source" = "";
              "browser.newtabpage.directory.ping" = "";
              "browser.newtabpage.introShown" = true;

              # avoid random sounds
              "media.autoplay.default" = 1; # 0 = Allowed, 1 = Blocked, 2 = Prompt
              "media.autoplay.allow-muted" = false;
              "media.block-autoplay-until-in-foreground" = true;
              "accessibility.typeaheadfind.enablesound" = false;

              # privacy settings
              "browser.topsites.contile.cachedTiles" = "";
              # while recommended for privacy, this breaks p2p (google meet for example)
              "media.peerconnection.ice.default_address_only" = false;
              "media.peerconnection.enabled" = true;
              "browser.urlbar.suggest.engines" = false;
              "browser.urlbar.suggest.topsites" = false;
              "browser.urlbar.trending.featureGate" = false;
              "browser.urlbar.mdn.featureGate" = false;
              "browser.urlbar.weather.featureGate" = false;
              # extracted from https://github.com/pyllyukko/user.js/blob/master/user.js
              "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
              # Managed by policy
              # "network.trr.mode" = 3; # 0 = off (default), 1 = <reserved>, 2 = first, 3 = only, 4 = <reserved>, 5 = off by choice
              "network.dns.echconfig.enabled" = true;
              "network.dns.http3_echconfig.enabled" = true;
              "browser.safebrowsing.malware.enabled" = false;
              "browser.safebrowsing.phishing.enabled" = false;
              "browser.safebrowsing.downloads.enabled" = false;
              "browser.startup.page" = 3; # 0 = blank, 1 = home, 2 = last visited page, 3 = resume previous session
              "browser.newtabpage.activity-stream.system.showSponsored" = false;
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

              "network.http.sendRefererHeader" = 2; # 1 = don't send any, 1 = send only on clicks, 2 = send on image requests as well
              # smart referer addon takes care of this
              # "network.http.referer.spoofSource" = false; # false=real referer, true=spoof referer (use target URI as referer)
              # "network.http.referer.trimmingPolicy" = 2; # 0 = full URI, 1 = scheme+host+port+path, 2 = scheme+host+port

              "media.eme.enabled" = true; # enable DRM, needed for playing MP4 videos :(

              "browser.tabs.groups.enabled" = true;

              "sidebar.revamp" = true;
              "sidebar.revamp.round-content-area" = true;
              "sidebar.verticalTabs" = true;
              "sidebar.position_start" = true;

              "intl.accept_languages" = lib.concatStringsSep ", " [
                "en-US"
                "en"
              ];
              "extensions.webextensions.restrictedDomains" = lib.concatStringsSep "" [
                # "accounts-static.cdn.mozilla.net"
                # "accounts.firefox.com"
                # "addons.cdn.mozilla.net"
                # "addons.mozilla.org"
                # "api.accounts.firefox.com"
                # "content.cdn.mozilla.net"
                # "discovery.addons.mozilla.org"
                # "install.mozilla.org"
                # "oauth.accounts.firefox.com"
                # "profile.accounts.firefox.com"
                # "support.mozilla.org"
                # "sync.services.mozilla.com"
              ];
            }
          );
      };
      mkExtensionUrl = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
      mkExtension =
        {
          name,
          installation_mode ? "normal_installed", # normal_installed, force_installed, blocked, allowed
          install_url ? (mkExtensionUrl name),
          install_sources ? [ ],
          allowed_types ? [
            "extension"
            "theme"
            "dictionary"
            "locale"
          ],
          blocked_install_message ? null,
          restricted_domains ? [ ],
          updates_disabled ? false,
          default_area ? "menupanel", # menupanel, navbar
        }:
        {
          inherit
            name
            installation_mode
            install_url
            install_sources
            allowed_types
            blocked_install_message
            restricted_domains
            updates_disabled
            default_area
            ;
        };
      mkAutoconfig =
        let
          statusFunctionName = {
            locked = "lockPref";
            default = "defaultPref";
            user = "pref";
            clear = "clearPref";
          };
        in
        name: value:
        {
          status ? "user",
        }:
        ''
          ${statusFunctionName.${status}}(${builtins.toJSON name}, ${builtins.toJSON value});
        '';
    in
    {
      packages.firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped firefoxConfig;
    };
}
