{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.hosts;
  inherit (config) users common nixos;
  configs = builtins.mapAttrs (_: host: host.finalSystem) cfg;
  inherit (lib) types mkOption mkIf;
  isHmEnabledForUserAndHost = user: hostName: user.homeManager.enable && user.homeManager.hosts.${hostName};
in {
  _file = ./.;

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
          mainUser = mkOption {
            type = types.str;
            default = "root";
          };
          finalSystem = mkOption {
            type = types.unspecified;
            readOnly = true;
          };
        };

        config = {
          mainUser = let
            normalUsers = lib.filterAttrs (_: u: u.isNormalUser) config.finalSystem.config.users.users;
            userNames = lib.attrNames normalUsers;
          in
            mkIf (lib.length userNames == 1) (lib.mkDefault (lib.elemAt userNames 0));
          finalModules =
            nixos.sharedModules
            ++ [
              {nixpkgs.hostPlatform = config.system;}
              {networking.hostName = name;}
              ../../hosts/common/global
            ]
            ++ config.modules
            ++ lib.mapAttrsToList (username: user: let
              isEnabled = isHmEnabledForUserAndHost user name;
            in
              mkIf isEnabled {
                imports = [
                  inputs.home-manager.nixosModules.home-manager
                ];
                home-manager = {
                  users."${user.name}" = {
                    imports =
                      user.homeManager.finalModules ++ lib.optional (user.homeManager.hostOverrides.${name} != null) (user.homeManager.hostOverrides.${name});
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
    homeManager.sharedModules = [
      ({config, ...}: {
        programs.ssh = {
          enable = true;
          matchBlocks =
            lib.mapAttrs (name: hostConfig: {
              hostname = hostConfig.finalSystem.config.networking.hostName;
              user = hostConfig.mainUser;
            })
            cfg;
        };
      })
    ];
    flake = {
      nixosConfigurations = configs;
    };
  };
}
