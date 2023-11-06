{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    dbeaver
    nil
    nixfmt
    nodePackages.pnpm
    rnix-lsp
    statix
  ];
}
