{...}: {
  imports = [
    ./hardware-configuration.nix
    ../common/optional/ssh/server.nix
  ];
}
