{lib, ...}: let
  inherit (lib) mkOption types;
in {
  _file = ./nix.nix;

  options.nix = mkOption {
    type = types.submodule ({config, ...}: {
      options = {
        experimental-features = mkOption {
          type = types.listOf types.str;
          default = ["nix-command" "flakes" "no-url-literals" "repl-flake"];
        };
        trusted-users = mkOption {
          type = types.listOf types.str;
          default = ["@wheel"];
        };
        auto-optimise-store = mkOption {
          type = types.bool;
          default = true;
        };
        binaryCaches = mkOption {
          type = types.listOf (types.submodule (_: {
            options = {
              url = mkOption {type = types.str;};
              publicKey = mkOption {type = types.str;};
            };
          }));
          default = [
            {
              url = "https://nix-community.cachix.org";
              publicKey = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
            }
            {
              url = "https://nushell-nightly.cachix.org";
              publicKey = "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc=";
            }
          ];
        };
        keep-outputs = mkOption {
          type = types.bool;
          default = true;
        };
        substituters = mkOption {
          type = types.listOf types.str;
        };
        trusted-public-keys = mkOption {
          type = types.listOf types.str;
        };
      };
      config = {
        substituters = builtins.map (value: value.url) config.binaryCaches;
        trusted-public-keys = builtins.map (value: value.publicKey) config.binaryCaches;
      };
    });
    default = {};
  };
}
