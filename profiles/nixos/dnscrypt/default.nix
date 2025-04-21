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
    services.dnscrypt-proxy2 = lib.mkDefault {
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
                # via = [ "*" ];
                via = map (name: "anon-${name}") anonServers;
              }
            ];
          };
          sources =
            let
              mkCachePath = name: "/var/cache/dnscrypt-proxy/${name}";
            in
            {
              public-resolvers = {
                urls = [
                  "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                  "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                ];
                cache_file = mkCachePath "public-resolvers.md";
                minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                refresh_delay = 73;
                prefix = "";
              };
              relays = {
                urls = [
                  "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                  "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
                ];
                cache_file = mkCachePath "relays.md";
                minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                refresh_delay = 73;
                prefix = "";
              };
              # odoh-servers = {
              #   urls = [
              #     "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
              #     "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
              #   ];
              #   cache_file = mkCachePath "odoh-servers.md";
              #   minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              #   refresh_delay = 73;
              #   prefix = "";
              # };
              # odoh-relays = {
              #   urls = [
              #     "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
              #     "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
              #   ];
              #   cache_file = mkCachePath "odoh-relays.md";
              #   minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              #   refresh_delay = 73;
              #   prefix = "";
              # };
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
      fallbackDns = [
        #   "9.9.9.9#dns.quad9.net"
        #   "149.112.112.112#dns.quad9.net"
        #   "2620:fe::fe#dns.quad9.net"
        #   "2620:fe::9#dns.quad9.net"

      ];
      dnssec = "false";
      domains = [ "~." ];
    };

    networking = {
      nameservers = if config.services.resolved.enable then [ "127.0.0.1:54" ] else [ "127.0.0.1" ];
    };

    programs.firefox = {
      policies = lib.mkIf config.services.dnscrypt-proxy2.enable {
        # force to use the system DNS
        DNSOverHTTPS.Enabled = lib.mkDefault false;
      };
    };

    environment.systemPackages = [
      (pkgs.my.mkWrapper {
        basePackage = pkgs.dnscrypt-proxy;
        flags = [
          "-config"
          config.services.dnscrypt-proxy2.configFile
        ];
      })
    ];

    programs.captive-browser = lib.mkDefault {
      enable = true;
      interface = "wlan0";
    };
  };

}
