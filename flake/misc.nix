{
  inputs,
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

  parts = {
    nixpkgs = {
      enable = true;
      config = {
        allowUnfree = lib.mkDefault true;
        allowAliases = lib.mkDefault false;
      };
      overlays = [
        # (_final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system})
      ];
    };

    home-manager.modules = [
      {
        _file = ./misc.nix;
        nix.gc = lib.mkDefault {
          automatic = true;
          frequency = "weekly";
        };
      }
    ];
    nixos.modules = [
      {
        _file = ./misc.nix;
        nix.gc = lib.mkDefault {
          automatic = true;
          dates = "weekly";
        };

      }
    ];

    common = {
      specialArgs = {
        inherit inputs;
      };
      exclusiveModules = [
        (
          { pkgs, config, ... }:
          {
            _file = ./misc.nix;
            nix =
              let
                isLix = lib.getName config.nix.package == "lix";
              in
              {
                package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
                settings = {
                  allowed-users = lib.mkDefault [ "@wheel" ];
                  min-free = lib.mkDefault 128000000; # 128MB
                  max-free = lib.mkDefault 1000000000; # 1GB
                  connect-timeout = lib.mkDefault 5;
                  fallback = lib.mkDefault true;
                  log-lines = lib.mkDefault 50;
                  auto-optimise-store = lib.mkDefault true;
                  experimental-features =
                    [
                      "nix-command"
                      "flakes"
                      "auto-allocate-uids"
                    ]
                    ++ lib.optionals isLix [
                      "pipe-operator"
                    ];
                  keep-outputs = lib.mkDefault true;
                  auto-allocate-uids = lib.mkDefault true;
                  narinfo-cache-negative-ttl = lib.mkDefault 0;
                  use-xdg-base-directories = lib.mkDefault true;
                  warn-dirty = lib.mkDefault false;
                  # remove global registry
                  flake-registry = lib.mkDefault "";
                  sync-before-registering = true;
                  accept-flake-config = lib.mkIf isLix (lib.mkDefault false);
                  repl-overlays = lib.mkIf isLix [
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
}
