{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # corepack
    # file
    dbeaver-bin
    git-extras
    git-standup
    nil
    nixfmt-rfc-style
    pnpm
    scrcpy
    statix
    yarn-berry
  ];

  # includes android-tools
  programs.adb.enable = true;

  programs.npm.enable = true;
}
