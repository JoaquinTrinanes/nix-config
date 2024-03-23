{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # corepack
    # file
    dbeaver
    git-extras
    git-standup
    nil
    nixfmt-rfc-style
    nodePackages.pnpm
    scrcpy
    statix
    yarn-berry
  ];

  # includes android-tools
  programs.adb.enable = true;

  programs.npm.enable = true;
}
