{
  self,
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ ../pkgs ];

  perSystem =
    { pkgs, lib, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };

  system-parts = {
    nixpkgs.config.allowUnfree = true;
    common = {
      stateVersion = lib.mkDefault "23.11";
      modules = [
        {
          _module.args = {
            inherit (config.system-parts) users;
            hosts = lib.mapAttrs (_: h: h.finalSystem.config) config.system-parts.nixos.hosts;
          };
        }
      ];
      specialArgs = {
        inherit self inputs;
      };
      exclusiveModules = [
        (
          { pkgs, ... }:
          {
            nix = {
              # use older nix while HM issue #4692 isn't fixed
              package = lib.mkDefault pkgs.nixVersions.nix_2_18;
              # package = lib.mkDefault pkgs.nixVersions.unstable;

              settings = {
                allowed-users = lib.mkDefault [ "@wheel" ];
                min-free = lib.mkDefault 128000000; # 128MB
                max-free = lib.mkDefault 1000000000; # 1GB
                connect-timeout = lib.mkDefault 5;
                fallback = lib.mkDefault true;
                log-lines = lib.mkDefault 50;
                auto-optimise-store = lib.mkDefault true;
                experimental-features = [
                  "nix-command"
                  "flakes"
                  "repl-flake"
                  "ca-derivations"
                  "auto-allocate-uids"
                ];
                keep-outputs = lib.mkDefault true;
                auto-allocate-uids = lib.mkDefault true;
                narinfo-cache-negative-ttl = lib.mkDefault 0;
                use-xdg-base-directories = lib.mkDefault true;
              };
            };
          }
        )
      ];
    };
    overlays = {
      all = import ../overlays { inherit inputs; };
      enabled = _: [ ];
    };
  };

  flake = {
    nixosModules = import ../modules/nixos;
    homeManagerModules = import ../modules/home-manager;
  };
}
