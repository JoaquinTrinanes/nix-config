{ inputs, lib, ... }:
{
  parts.nixos = {
    hosts = {
      "razer-blade-14" = {
        system = "x86_64-linux";
        modules = [ ../hosts/razer-blade-14 ];
      };
      "media-server" = {
        system = "x86_64-linux";
        modules = [ ../hosts/media-server/desktop.nix ];
      };
    };

    modules = lib.mkMerge [
      (builtins.attrValues inputs.self.modules.nixos)
      [
        ../hosts/common/global.nix
        ../profiles/nixos
      ]
    ];
  };
}
