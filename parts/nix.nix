{
  lib,
  self,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (config) hosts users;
  cfg = config.nix;
  commonModules = [
    {
      nix.settings = {
        trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc="];
        substituters = ["https://nix-community.cachix.org" "https://nushell-nightly.cachix.org"];
        experimental-features = ["nix-command" "flakes" "no-url-literals" "repl-flake"];
        trusted-users = ["@wheel"];
      };
    }
  ];
in {
  _file = ./nix.nix;

  options.nix = {
    specialArgs = mkOption {
      type = types.submodule {
        freeformType = types.anything;
      };
    };
    stateVersion = mkOption {type = types.str;};
  };

  config = {
    nix.stateVersion = "23.11";
    homeManager = {
      sharedModules =
        commonModules
        ++ [
          {
            home.stateVersion = cfg.stateVersion;
          }
        ];
      standaloneModules = [({pkgs, ...}: {nix.package = pkgs.nixVersions.nix_2_18;})];
    };
    nixos.sharedModules =
      commonModules
      ++ [
        ({pkgs, ...}: {
          # use older nix while HM issue #4692 isn't fixed
          # nix.package = pkgs.nixVersions.unstable;
          nix.package = pkgs.nixVersions.nix_2_18;

          system.stateVersion = cfg.stateVersion;
        })
      ];
    nix = {
      specialArgs = {inherit self inputs hosts users;};
    };
  };
}
