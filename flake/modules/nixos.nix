{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.hosts;
  inherit (config) users nix nixos;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg;
  inherit (lib) types mkOption mkIf;
  isHmEnabledForHost = user: hostName: user.homeManager.enable; # && user.homeManager.hostOverrides.${hostName} != null;
in {
  _file = ./nixos.nix;

  options = {
    nixos.sharedModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
    };
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({
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
              ../../hosts/common/global
            ]
            ++ config.modules
            ++ lib.mapAttrsToList (username: user: let
              isEnabled = isHmEnabledForHost user name;
            in
              mkIf isEnabled {
                imports = [
                  inputs.home-manager.nixosModules.home-manager
                ];
                home-manager = {
                  users."${user.name}" = {
                    imports =
                      user.homeManager.finalModules;
                  };
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = {inherit user;} // nix.specialArgs;
                };
              })
            users;

          finalSystem = config.nixpkgs.lib.nixosSystem {
            modules = config.finalModules;
            specialArgs = nix.specialArgs;
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
