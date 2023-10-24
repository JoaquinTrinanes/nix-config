{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  # nixpkgs = {
  #   overlays = with outputs.overlays; [
  #     additions
  #     modifications
  #     unstable-packages
  #     neovim-nightly
  #   ];
  #
  #   # Configure your nixpkgs instance
  #   config = {
  #     # Disable if you don't want unfree packages
  #     allowUnfree = true;
  #   };
  # };

  # nix = {
  #   # This will add each flake input as a registry
  #   # To make nix3 commands consistent with your flake
  #   registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
  #
  #   package = lib.mkDefault pkgs.nix;
  #
  #   settings = {
  #     # Enable flakes and new 'nix' command
  #     experimental-features = "nix-command flakes";
  #     # Deduplicate and optimize nix store
  #     auto-optimise-store = true;
  #     substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org/"];
  #     trusted-public-keys = [
  #       "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #     ];
  #   };
  # };
}
