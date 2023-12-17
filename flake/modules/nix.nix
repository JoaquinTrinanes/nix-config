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
in {
  _file = ./nix.nix;

  options.nix = {
    globalModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
    };
    specialArgs = mkOption {
      type = types.submodule {
        freeformType = types.anything;
      };
    };
    stateVersion = mkOption {type = types.str;};
  };

  config = {
    homeManager = {
      sharedModules = cfg.globalModules ++ [{home.stateVersion = cfg.stateVersion;}];
      standaloneModules = [({pkgs, ...}: {nix.package = pkgs.nixVersions.nix_2_18;})];
    };
    nixos.sharedModules =
      cfg.globalModules
      ++ [
        ({pkgs, ...}: {
          # use older nix while HM issue #4692 isn't fixed
          # nix.package = pkgs.nixVersions.unstable;
          nix.package = pkgs.nixVersions.nix_2_18;

          system.stateVersion = cfg.stateVersion;
        })
      ];
    nix = {
      globalModules = [
        {
          nix.settings = {
            experimental-features = ["nix-command" "flakes" "repl-flake"];
          };
        }
      ];
      specialArgs = {inherit self inputs hosts users;};
      stateVersion = "23.11";
    };
  };
}
