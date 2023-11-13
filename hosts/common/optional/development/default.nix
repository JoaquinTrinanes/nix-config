{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    dbeaver
    nil
    nixfmt
    nodePackages.pnpm
    rnix-lsp
    statix
    scrcpy
  ];

  # includes android-tools
  programs.adb.enable = true;
}
