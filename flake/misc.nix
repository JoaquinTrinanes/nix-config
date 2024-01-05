{
  self,
  inputs,
  config,
  lib,
  ...
}: {
  _file = ./misc.nix;

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    formatter = pkgs.writeShellScriptBin "alejandra" ''
      exec ${lib.getExe pkgs.alejandra} --quiet "$@"
    '';

    packages = import ../pkgs pkgs;
  };

  my.common = {
    stateVersion = lib.mkDefault "23.11";
    specialArgs = {
      inherit self inputs;
      inherit (config.my) users;
      hosts = lib.mapAttrs (_: h: h.finalSystem.config) config.my.hosts;
    };
    modules = [
      ({
        pkgs,
        lib,
        ...
      }: {
        nix = {
          # use older nix while HM issue #4692 isn't fixed
          package = lib.mkDefault pkgs.nixVersions.nix_2_18;
          # package = lib.mkDefault pkgs.nixVersions.unstable;

          settings = {
            min-free = 128000000; # 128MB
            max-free = 1000000000; # 1GB
            connect-timeout = 5;
            fallback = true;
            log-lines = 25;
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
              "repl-flake"
              "ca-derivations"
            ];
            keep-outputs = true;
          };
        };
      })
    ];
  };

  my.overlays = {
    all = import ../overlays {inherit inputs;};
    enabled = o:
      builtins.attrValues {
        inherit
          (o) #additions
          modifications
          ;
      };
  };

  flake = {
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ../../modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ../modules/home-manager;
  };
}
