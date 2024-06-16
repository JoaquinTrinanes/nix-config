{ self, ... }:
{
  system-parts.nixos = {
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

    modules = builtins.attrValues self.nixosModules ++ [ ../hosts/common/global.nix ];
  };
}
