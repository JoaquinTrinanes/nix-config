{user, ...}: {
  imports = [./aliases.nix ./color.nix];
  programs.git = {
    enable = true;
    extraConfig = {
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
      # credential.helper = "cache --timeout=3600";
      # credential.helper = "${
      #   pkgs.git.override {withLibsecret = true;}
      # }/bin/git-credential-libsecret";
      init.defaultBranch = "main";
      user = {
        inherit (user) email;
        name = user.fullName;
      };
    };
    includes = [
      {
        condition = "gitdir:~/Documents/veganhacktivists/";
        contents = {
          user.email = "joaquin@veganhacktivists.org";
        };
      }
    ];
  };
}
