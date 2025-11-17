{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      git-branchless
      git-extras
      ;
  };

  home.shellAliases = {
    g = "git";
    ga = "git add";

    gb = "git branch";
    gbd = "git branch --delete";
    gbD = "git branch --delete --force";

    gco = "git checkout";
    gcp = "git cherry-pick";

    gd = "git diff";

    gf = "git fetch";

    gl = "git pull";

    gm = "git merge";
    gma = "git merge --abort";

    gp = "git push";
    gpf = "git push --force-with-lease";
    "gpf!" = "git push --force";

    grb = "git rebase";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";

    gs = "git status --short --branch";
  };

  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      format = "openpgp";
      key = "6E1446DD451C6BAF";
      signByDefault = true;
    };
    settings = {
      user = {
        name = config.accounts.email.accounts.primary.realName;
        email = config.accounts.email.accounts.primary.address;
      };
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
      help.autocorrect = "immediate";
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
        "git@github.com/".pushInsteadOf = [
          "https://github.com/"
        ];
        "https://gitlab.com/".insteadOf = "gl:";
        "git@github.com:".insteadOf = "ghs:";
      };
      alias = {
        a = "add";
        b = "branch -vv";
        c = "commit";
        co = "checkout";
        cp = "cherry-pick";
        d = "diff";
        p = "push";
        pf = "push --force-with-lease";
        pnv = "push --no-verify";
        s = "status --short --branch";
        up = "pull --rebase";
      };

    };
    includes = [
      { path = "config.local"; }
      {
        condition = "gitdir:~/Documents/cawa/";
        contents = {
          user.email = config.accounts.email.accounts.cawa.address;
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
