{lib, ...}: let
  substituters = [
    "https://nix-community.cachix.org"
    "https://nushell-nightly.cachix.org"
    "https://cuda-maintainers.cachix.org?priority=100"
    "https://numtide.cachix.org"
    # "https://nix-shell.cachix.org"
    # "https://php-src-nix.cachix.org"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nushell-nightly.cachix.org-1:nLwXJzwwVmQ+fLKD6aH6rWDoTC73ry1ahMX9lU87nrc="
    "nix-shell.cachix.org-1:kat3KoRVbilxA6TkXEtTN9IfD4JhsQp1TPUHg652Mwc="
    "php-src-nix.cachix.org-1:3IMVbxfljrbI1NZjuML/2eHLsmHEXfzKGY0kEA20qWY="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];
in {
  my.nixos.sharedModules = [
    {
      nix.settings = {
        # mkAfter ensures the nixos cache goes first
        substituters = lib.mkAfter substituters;
        inherit trusted-public-keys;
      };
    }
  ];
}
