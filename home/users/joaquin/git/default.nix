{ config, ... }:
{
  imports = [
    ./aliases.nix
    ./color.nix
    ./sign.nix
  ];
  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = config.accounts.email.accounts.primary.realName;
        email = config.accounts.email.accounts.primary.address;
      };
      core = {
        filemode = false;
        whitespace = "trailing-space,space-before-tab";
      };
      commit.verbose = true;
      diff = {
        mnemonicprefix = true;
        # tool = "meld";
      };
      difftool.prompt = false;
      # icdiff.options = "--line-numbers";
      format.numbered = "auto";
      log.decorate = "short";
      merge = {
        conflictStyle = "diff3";
        log = false;
        # tool = "meld";
      };
      mergetool = {
        keepBackup = false;
        prompt = false;
      };
      pager = {
        color = true;
        show-branch = true;
      };
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      help.autocorrect = 1;
      rebase.autosquash = true;
      status.showUntrackedFiles = "normal"; # "all";
      init.defaultBranch = "main";
    };
    includes = [
      {
        condition = "gitdir:~/Documents/veganhacktivists/";
        contents = {
          user.email = config.accounts.email.accounts.vh.address;
        };
      }
    ];

    ignores = [
      "*.swp"
      ".env"

      # Mac
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"

      ## Thumbnails
      "._*"

      ## Files that might appear in the root of a volume
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"

      ## Directories potentially created on remote AFP share
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        shortTimeFormat = "15:04";
      };
    };
  };
}
