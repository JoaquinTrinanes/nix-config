{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # corepack
    # file
    alejandra
    dbeaver
    git-extras
    git-standup
    nil
    nixfmt
    nodePackages.pnpm
    scrcpy
    statix
    yarn-berry
  ];

  # includes android-tools
  programs.adb.enable = true;

  programs.npm.enable = true;
}
