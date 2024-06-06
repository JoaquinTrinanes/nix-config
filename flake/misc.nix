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
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };

  system-parts = {
    nixpkgs = {
      enable = true;
      config = {
        allowUnfree = lib.mkDefault true;
        allowAliases = lib.mkDefault false;
      };
    };

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
              # much faster eval for now, slower >2.20, nix issue #10437
              package = lib.mkDefault (
                # 2.20 doesn't have the symlink fix backported yet :(
                pkgs.nixVersions.nix_2_20.overrideAttrs (_oldAttrs: {
                  src = pkgs.fetchFromGitHub {
                    owner = "NixOS";
                    repo = "nix";
                    # 2.20-maintenance
                    rev = "2cb5f579bf69d29a774f0d34181b095c5df1e4c6";
                    hash = "sha256-Y8k1296wpfLHcpeJQc2cxcBOm3/j3kxe0oCydtfJkb8=";
                  };
                })
              );

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
                  "ca-derivations"
                  "auto-allocate-uids"
                ];
                keep-outputs = lib.mkDefault true;
                auto-allocate-uids = lib.mkDefault true;
                narinfo-cache-negative-ttl = lib.mkDefault 0;
                use-xdg-base-directories = lib.mkDefault true;
                warn-dirty = false;
                # remove global registry
                flake-registry = "";
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
