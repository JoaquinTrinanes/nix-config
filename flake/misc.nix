{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ ../pkgs ];

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };

  system-parts = {
    nixpkgs = {
      input = inputs.nixpkgs;
      enable = true;
      config = {
        allowUnfree = lib.mkDefault true;
        allowAliases = lib.mkDefault false;
      };
      overlays = [
        inputs.lix-module.overlays.default
        # (_final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system})
      ];
    };

    common = {
      modules = [
        {
          _file = ./misc.nix;
          _module.args = {
            inherit (config.system-parts) users;
            hosts = lib.mapAttrs (_: h: h.finalSystem.config) config.system-parts.nixos.hosts;
          };
        }
      ];
      specialArgs = {
        inherit inputs;
      };
      exclusiveModules = [
        (
          { pkgs, config, ... }:
          {
            _file = ./misc.nix;
            nix = {
              package = lib.mkDefault pkgs.nix;
              settings = {
                allowed-users = lib.mkDefault [ "@wheel" ];
                min-free = lib.mkDefault 128000000; # 128MB
                max-free = lib.mkDefault 1000000000; # 1GB
                connect-timeout = lib.mkDefault 5;
                fallback = lib.mkDefault true;
                log-lines = lib.mkDefault 50;
                auto-optimise-store = lib.mkDefault true;
                experimental-features = [
                  "repl-flake"
                  "nix-command"
                  "flakes"
                  "auto-allocate-uids"
                ];
                keep-outputs = lib.mkDefault true;
                auto-allocate-uids = lib.mkDefault true;
                narinfo-cache-negative-ttl = lib.mkDefault 0;
                use-xdg-base-directories = lib.mkDefault true;
                warn-dirty = lib.mkDefault false;
                # remove global registry
                flake-registry = lib.mkDefault "";

                repl-overlays = lib.mkIf (lib.getName config.nix.package == "lix") [
                  (pkgs.writeText "pkgs.nix"
                    # nix
                    ''
                      info: final: prev:
                      if prev ? legacyPackages && prev.legacyPackages ? ''${info.currentSystem} then
                        { pkgs = prev.legacyPackages.''${info.currentSystem}; }
                      else
                        { }
                    ''
                  )
                ];
              };
            };
          }
        )
      ];
    };
  };

  flake = {
    nixosModules = import ../modules/nixos;
    homeManagerModules = import ../modules/home-manager;
  };
}
