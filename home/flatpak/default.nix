{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = lib.mkDefault true;
    packages = [
      "com.github.tchx84.Flatseal"
      "com.slack.Slack"
    ];
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    overrides = {
      global = {
        Context = {
          filesystems = [
            "!host"
            "!home"
          ];
          sockets = [
            "wayland"
            "!x11"
            "!fallback-x11"
            "!session-bus"
            "!system-bus"
            "!gpg-agent"
            "!pcsc"
          ];
        };
      };
    };
  };

  home.packages = builtins.attrValues {
    inherit (pkgs) bazaar flatpak;
  };

  xdg.systemDirs.data = [
    "$HOME/.local/share/flatpak/exports/share"
  ];
  home.sessionPath = [
    "$HOME/.local/share/flatpak/exports/bin"
  ];

}
