{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profiles.dnscrypt;
in
{

  options.profiles.dnscrypt = {
    enable = lib.mkEnableOption "dnscrypt profile" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnscrypt-proxy = lib.mkDefault {
      enable = true;
      settings =
        let
          anonServers = [
            "cs-barcelona"
            "cs-madrid"
            "cs-nl"
            "cs-fr"
          ];
        in
        {
          disabled_server_names = anonServers;

          anonymized_dns = {
            skip_incompatible = true;
            routes = [
              {
                server_name = "*";
                via = map (name: "anon-${name}") anonServers;
              }
            ];
          };
          listen_addresses =
            if config.services.resolved.enable then [ "127.0.0.1:54" ] else [ "127.0.0.1:53" ];

          dnscrypt_servers = true;
          doh_servers = false;
          odoh_servers = false;
          require_nolog = true;
          require_dnssec = true;
          require_nofilter = true;

        };
    };

    services.resolved = {
      enable = lib.mkDefault true;
      settings = {
        Resolve = {
          FallbackDns = [
            #   "9.9.9.9#dns.quad9.net"
            #   "149.112.112.112#dns.quad9.net"
            #   "2620:fe::fe#dns.quad9.net"
            #   "2620:fe::9#dns.quad9.net"
          ];
          Domains = [ "~." ];
          DNSSEC = "false";
        };
      };
    };

    networking = {
      nameservers = if config.services.resolved.enable then [ "127.0.0.1:54" ] else [ "127.0.0.1" ];
    };

    programs.firefox = {
      policies = lib.mkIf config.services.dnscrypt-proxy.enable {
        # force to use the system DNS
        DNSOverHTTPS.Enabled = lib.mkDefault false;
      };
    };

    environment.systemPackages = [
      (pkgs.my.mkWrapper {
        basePackage = pkgs.dnscrypt-proxy;
        prependFlags = [
          "-config"
          config.services.dnscrypt-proxy.configFile
        ];
      })
    ];

    programs.captive-browser = lib.mkDefault {
      enable = true;
      interface = "wlan0";
    };
  };

}
