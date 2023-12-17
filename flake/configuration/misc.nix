{
  self,
  inputs,
  ...
}: {
  _file = ./misc.nix;

  config.perSystem = {
    pkgs,
    lib,
    ...
  }: {
    formatter = pkgs.writeShellScriptBin "alejandra" ''
      exec ${lib.getExe pkgs.alejandra} --quiet "$@"
    '';

    packages = import ../../pkgs pkgs;
  };

  config.overlays = import ../../overlays {inherit self inputs;};

  config.flake = {
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ../../modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ../../modules/home-manager;
  };
}
