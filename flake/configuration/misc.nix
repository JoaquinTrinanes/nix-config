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

    packages = import ../../pkgs pkgs;
  };

  common = {
    stateVersion = lib.mkDefault "23.11";
    specialArgs = {
      inherit self inputs;
      inherit (config) hosts users;
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
            auto-optimise-store = true;
            experimental-features = ["nix-command" "flakes" "repl-flake" "ca-derivations"];
            keep-outputs = true;
          };
        };
      })
    ];
  };

  overlays = import ../../overlays {inherit self inputs;};
  flake = {
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ../../modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ../../modules/home-manager;
  };
}
