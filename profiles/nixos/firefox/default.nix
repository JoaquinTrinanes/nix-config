{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.profiles.firefox;
  firefoxCfg = config.programs.firefox;
in
{
  options.profiles.firefox = {
    enable = lib.mkEnableOption "firefox profile";
  };

  config =
    let
      inherit (inputs.self.packages.${pkgs.stdenv.hostPlatform.system}) firefox;
      firefoxWithConfig = firefox.override (prev: {
        extraPolicies = lib.recursiveUpdate prev.extraPolicies (
          lib.recursiveUpdate firefoxCfg.policies {
            Preferences = lib.mapAttrs' (
              key: value:
              lib.nameValuePair key {
                Value = value;
                Status = firefoxCfg.preferencesStatus;
              }
            ) firefoxCfg.preferences;
          }
        );
      });

    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [ firefoxWithConfig ];
      programs.firefox = {
        enable = false;

        # allow changing without rebuilds
        preferencesStatus = "user";

        package = firefoxWithConfig;
      };

      xdg.mime.defaultApplications =
        let
          defaultWebBrowser = [
            config.programs.firefox.package.desktopItem.name or "firefox.desktop"
          ];
        in
        {
          "x-scheme-handler/http" = defaultWebBrowser;
          "x-scheme-handler/https" = defaultWebBrowser;
          "x-scheme-handler/chrome" = defaultWebBrowser;
          "text/html" = defaultWebBrowser;
          "application/x-extension-htm" = defaultWebBrowser;
          "application/x-extension-html" = defaultWebBrowser;
          "application/x-extension-shtml" = defaultWebBrowser;
          "application/xhtml+xml" = defaultWebBrowser;
          "application/x-extension-xhtml" = defaultWebBrowser;
          "application/x-extension-xht" = defaultWebBrowser;
        };
    };
}
