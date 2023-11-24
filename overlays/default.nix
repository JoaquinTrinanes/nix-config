{
  inputs,
  lib,
  config,
  withSystem,
  ...
}: {
  flake.overlays = {
    # This one brings our custom packages from the 'pkgs' directory
    # additions = final: prev: config.flake.packages.${final.system} or {};
    additions = final: prev: withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    # config.flake.packages.${final.system} or {};

    # additions = final: prev: import ../pkgs final {inherit inputs;};
    # additions = _: _: {};

    # This one contains whatever you want to overlay
    # You can change versions, add patches, set compilation flags, anything really.
    # https://nixos.wiki/wiki/Overlays
    modifications = final: prev: {
      # example = prev.example.overrideAttrs (oldAttrs: rec {
      # ...
      # });
    };

    # When applied, the unstable nixpkgs set (declared in the flake inputs) will
    # be accessible through 'pkgs.unstable'
    # unstable-packages = final: _prev: {
    #   unstable = import inputs.nixpkgs-unstable {
    #     inherit (final) system;
    #     config.allowUnfree = true;
    #   };
    # };

    # For every flake input, aliases 'pkgs.inputs.${flake}' to
    # 'inputs.${flake}.packages.${pkgs.system}' or
    # 'inputs.${flake}.legacyPackages.${pkgs.system}'
    flake-inputs = final: _: {
      inputs =
        builtins.mapAttrs
        (
          _: flake: let
            legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
            packages = (flake.packages or {}).${final.system} or {};
          in
            if legacyPackages != {}
            then legacyPackages
            else packages
        )
        inputs;
    };

    neovim-nightly = inputs.neovim-nightly-overlay.overlay;

    nur = inputs.nur.overlay;

    default = lib.composeManyExtensions (with config.flake.overlays; [
      # flake-inputs
      additions
      modifications
      neovim-nightly
      nur
    ]);
  };
}
