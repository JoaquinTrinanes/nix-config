{ inputs, lib, ... }:
{
  parts.nixos = {
    hosts = {
      piorno = {
        system = "x86_64-linux";
        modules = [
          ../hosts/common/desktop.nix
          ../hosts/piorno/hardware-configuration.nix
          ../hosts/piorno/disko.nix
        ];
      };
      razer-blade-14 = {
        system = "x86_64-linux";
        modules = [
          ../hosts/common/desktop.nix
          ../hosts/razer-blade-14/hardware-configuration.nix
          ../hosts/razer-blade-14/disko.nix
        ];
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
