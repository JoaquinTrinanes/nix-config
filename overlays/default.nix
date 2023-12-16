{
  inputs,
  withSystem,
  ...
}: {
  _file = ./default.nix;

  config.overlays = {
    # This one brings our custom packages from the 'pkgs' directory
    # additions = final: prev: config.flake.packages.${final.system} or {};
    additions = final: prev: withSystem prev.stdenv.hostPlatform.system ({self', ...}: self'.packages);

    # This one contains whatever you want to overlay
    # You can change versions, add patches, set compilation flags, anything really.
    # https://nixos.wiki/wiki/Overlays
    modifications = final: prev: {
      # nushell = prev.nushell-nightly;
      # nushellFull = prev.nushell-nightly.override {
      #   additionalFeatures = p: (p ++ ["extra" "dataframe"]);
      # };
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
    # pkgs.stdenv.hostPlatform.system
    flake-inputs = final: _: {
      inputs =
        builtins.mapAttrs
        (
          _: flake: let
            inherit (final.stdenv.hostPlatform) system;
            legacyPackages = (flake.legacyPackages or {}).${system} or {};
            packages = (flake.packages or {}).${system} or {};
          in
            if legacyPackages != {}
            then legacyPackages
            else packages
        )
        inputs;
    };
  };
}
