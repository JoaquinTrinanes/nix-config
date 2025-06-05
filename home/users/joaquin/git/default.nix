{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./aliases.nix
  ];

  programs.git = {
    enable = true;
    signing = {
      format = "openpgp";
      key = "6E1446DD451C6BAF";
      signByDefault = true;
    };
    userName = config.accounts.email.accounts.primary.realName;
    userEmail = config.accounts.email.accounts.primary.address;
    extraConfig = {
      gpg.program = lib.getExe pkgs.sequoia-chameleon-gnupg;
      core = {
        filemode = false;
        whitespace = "trailing-space,space-before-tab";
      };
      commit = {
        verbose = true;
      };
      diff = {
        algorith = "histogram";
        renames = true;
        mnemonicPrefix = true;
      };
      difftool.prompt = false;
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      format.numbered = "auto";
      log = {
        decorate = "short";
        mailmap = true;
      };
      merge = {
        conflictStyle = "zdiff3";
        log = false;
        autoStash = true;
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
      help.autocorrect = "immedate";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      status.showUntrackedFiles = "normal"; # "all";
      init.defaultBranch = "main";
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      tag = {
        sort = "version:refname";
      };

      color = {
        ui = true;
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "blue bold";
        };
        status = {
          added = "yellow";
          changed = "magenta";
          untracked = "green";
        };
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
      };
      url = {
        "https://github.com/".insteadOf = [
          "gh:"
          "github:"
        ];
        "https://gitlab.com/".insteadOf = "gl:";
        "git@github.com:".insteadOf = "ghs:";
      };
    };
    includes = [
      { path = "config.local"; }
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
