{
  inputs,
  lib,
  config,
  self,
  ...
}: let
  cfg = config.my.hosts;
  inherit (config.my) users common nixos;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg;
  inherit (lib) types mkOption mkIf;
  isHmEnabledForUserAndHost = user: hostName: user.homeManager.enable && user.homeManager.hosts.${hostName}.enable or false;
in {
  _file = ./nixos.nix;

  options.my = {
    nixos.sharedModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "Modules shared across all nixos configurations";
    };
    hosts = mkOption {
      description = "Host configurations";
      type = types.attrsOf (types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          nixpkgs = mkOption {
            type = types.unspecified;
            default = inputs.nixpkgs;
            description = "Instance of nixpkgs";
          };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
            description = "Modules for this host";
          };
          system = mkOption {
            type = types.enum config.nixpkgs.lib.systems.flakeExposed;
          };
          finalModules = mkOption {
            type = types.listOf types.unspecified;
            readOnly = true;
          };
          finalSystem = mkOption {
            type = types.unspecified;
            readOnly = true;
          };
        };

        config = {
          finalModules =
            nixos.sharedModules
            ++ [
              {nixpkgs.hostPlatform = config.system;}
              {networking.hostName = name;}
              "${self}/hosts/common/global"
            ]
            ++ config.modules
            ++ lib.mapAttrsToList (username: user:
              mkIf (isHmEnabledForUserAndHost user name) {
                imports = [
                  inputs.home-manager.nixosModules.home-manager
                ];
                home-manager = {
                  users."${user.name}" = {
                    imports =
                      user.homeManager.finalModules ++ lib.optional user.homeManager.hosts.${name}.enable user.homeManager.hosts.${name}.override;
                  };
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = {inherit user;} // common.specialArgs;
                };
              })
            users;

          finalSystem = config.nixpkgs.lib.nixosSystem {
            modules = config.finalModules;
            inherit (common) specialArgs;
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
