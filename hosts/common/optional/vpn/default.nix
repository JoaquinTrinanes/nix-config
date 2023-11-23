{config, ...}: {
  sops.secrets."protonvpn/openvpn/username" = {
    sopsFile = ./secrets/credentials.yaml; # "%r/secrets/credentials.yaml";
  };
  sops.secrets."protonvpn/openvpn/password" = {
    sopsFile = ./secrets/credentials.yaml; # "%r/secrets/credentials.yaml";
  };
  sops.secrets."node-es-03.protonvpn.net.udp.ovpn" = {
    sopsFile = ./secrets/node-es-03.protonvpn.net.udp.ovpn; # "%r/secrets/credentials.yaml";
    format = "binary";
  };
  services.openvpn.servers = {
    protonSpain = {
      config = ''config ${config.sops.secrets."node-es-03.protonvpn.net.udp.ovpn".path}'';
    };
  };
}
