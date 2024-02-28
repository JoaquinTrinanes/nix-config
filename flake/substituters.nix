{lib, ...}: let
  substituters = [
    "https://nix-community.cachix.org"
    "https://nushell-nightly.cachix.org"
    "https://cuda-maintainers.cachix.org?priority=100"
    "https://numtide.cachix.org"
    "https://cache.garnix.io"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
  substituterSettings.nix.settings = {
    substituters = lib.mkAfter substituters;
    inherit trusted-public-keys;
  };
in {
  _file = ./substituters.nix;

  my.common.exclusiveModules = [substituterSettings];
}
