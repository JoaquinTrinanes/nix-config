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

    common = {
      modules = [
        {
          _file = ./misc.nix;
          _module.args = {
            inherit (config.parts) users;
            inherit inputs;
            hosts = lib.mapAttrs (_: h: h.finalSystem.config) config.parts.nixos.hosts;
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
            nix =
              let
                isLix = lib.getName config.nix.package == "lix";
              in
              {
                package = lib.mkDefault pkgs.lix;
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
                      "ca-derivations"
                    ]
                    ++ lib.optionals isLix [
                      "pipe-operator"
                      "repl-flake"
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
