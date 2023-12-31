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
    file
  ];

  # includes android-tools
  programs.adb.enable = true;

  programs.npm.enable = true;
}
