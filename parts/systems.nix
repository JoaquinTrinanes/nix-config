{
  self,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.hosts;
  users = config.users;
  nixpkgs = config.nixpkgs;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg;
  inherit (lib) types mkOption mkIf;
  isHmEnabledForHost = user: hostName: user.homeManager.hosts.${hostName} == true;
in {
  _file = ./systems.nix;

  options = {
    hosts = mkOption {
      type = types.lazyAttrsOf (types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          nixpkgs = mkOption {
            type = types.unspecified;
            default = inputs.nixpkgs;
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
          system = mkOption {
            type = types.enum inputs.nixpkgs.lib.systems.flakeExposed;
          };

          finalModules = mkOption {
            type = types.listOf types.unspecified;
            readOnly = true;
          };

          finalSystem = mkOption {
            type = types.unspecified;
            readOnly = true;
          };

          # finalPkgs = mkOption {
          #   type = types.unspecified;
          #   readOnly = true;
          # };
        };

        config = {
          finalModules =
            [
              {inherit nixpkgs;}
              {nixpkgs.hostPlatform = config.system;}
              {system.stateVersion = "23.11";}
              {networking.hostName = name;}
              ../hosts/common/global
            ]
            ++ config.modules
            ++ lib.mapAttrsToList (username: user: let
              isEnabled = isHmEnabledForHost user name;
            in
              mkIf isEnabled {
                imports = lib.singleton (
                  inputs.home-manager.nixosModules.home-manager
                );
                home-manager = {
                  users."${user.name}" = user.homeManager.path;
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = {inherit user inputs self;};
                };
              })
            users;

          finalSystem = config.nixpkgs.lib.nixosSystem {
            modules = config.finalModules;
            specialArgs = {
              inherit inputs self users;
              hosts = cfg;
            };
          };
        };
      }));
      default = {};
    };
  };

  config = {
    flake = {
      nixosConfigurations = configs;
    };
  };
}
