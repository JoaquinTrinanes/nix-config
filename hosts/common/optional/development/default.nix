{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    nil
    nixfmt
    nodePackages.pnpm
    rnix-lsp
    statix
  ];
}
