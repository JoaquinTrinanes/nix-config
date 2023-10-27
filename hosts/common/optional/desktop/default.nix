{pkgs, ...}: {
  # TODO: attr to override desired WM?
  imports = [./gnome.nix ./stylix.nix ../audio.nix];

  environment.systemPackages = with pkgs; [
    alejandra
    firefox
    nil
    git
    discord
    wget
    nil
    rnix-lsp
    nixfmt
    gcc
    libgcc
    libcxx
    stylua
    ripgrep
    sd
    fd
    fzf
    gnumake
    lua-language-server
    pciutils
    nix-index
    lshw
    unzip
  ];
  programs.dconf.enable = true;
}
