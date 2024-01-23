_: {
  # services.home-assistant = {
  #   enable = true;
  #   openFirewall = true;
  #   config = {};
  # };

  networking.firewall.allowedTCPPorts = [8123];
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [
        # "/var/home-assistant/config:/config"
        "home-assistant:/config"
      ];
      environment.TZ = "Europe/Madrid";
      image = "ghcr.io/home-assistant/home-assistant:2023.12.3"; # Warning: if the tag does not change, the image will not be updated
      # ports = ["8123:8213"];
      extraOptions = [
        "--network=host"
        # "--device=/dev/ttyACM0:/dev/ttyACM0" # Example, change this to match your own hardware
      ];
    };
  };
}
