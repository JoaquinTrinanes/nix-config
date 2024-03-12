{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.system-parts.hosts;
  inherit (config.system-parts) users common nixos;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg;
  inherit (lib) types mkOption mkIf;
  hostType = types.submodule ({
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
        nixos.modules
        ++ [
          {nixpkgs.hostPlatform = config.system;}
          {networking.hostName = name;}
        ]
        ++ config.modules
        ++ lib.mapAttrsToList (username: user:
          mkIf (user.homeManager.hosts.${name}.enable or false) {
            imports = [
              inputs.home-manager.nixosModules.home-manager
            ];
            home-manager = {
              users."${user.name}" = {
                imports =
                  user.homeManager.finalModules ++ [(user.homeManager.hosts.${name}.override config.finalSystem)];
              };
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = lib.recursiveUpdate common.specialArgs {inherit user;};
            };
          })
        users;

      finalSystem = config.nixpkgs.lib.nixosSystem {
        modules = config.finalModules;
        inherit (common) specialArgs;
      };
    };
  });
in {
  options.system-parts = {
    nixos.modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "Modules shared across all nixos configurations";
    };
    hosts = mkOption {
      description = "Host configurations";
      type = types.attrsOf hostType;
      default = {};
    };
  };

  config = {
    flake = {
      nixosConfigurations = configs;
    };
  };
}
