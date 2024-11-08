{
  config,
  lib,
  pkgs,
  ...
}:
let
  diffEditor = config.programs.neovim.package;
  # Workaround for jj not having includeIf
  jj = lib.my.mkWrapper {
    basePackage = pkgs.writeShellScriptBin "jj" ''
      if [[ $PWD/ = $HOME/Documents/veganhacktivists/* ]]; then
        export JJ_EMAIL=''${JJ_EMAIL-${lib.escapeShellArg config.accounts.email.accounts.vh.address}}
        # ${lib.toShellVar "JJ_EMAIL" config.accounts.email.accounts.vh.address}
      fi
      exec ${lib.getExe pkgs.jujutsu} "$@"
    '';

    # FIXME: https://nixpk.gs/pr-tracker.html?pr=352298
    env = {
      PAGER = {
        value = null;
      };
    };
    extraPackages = [
      (pkgs.writeTextDir "share/fish/vendor_completions.d/jj.fish" ''
        source ${pkgs.jujutsu}/share/fish/vendor_completions.d/jj.fish
        source ${./jj.fish}
      '')
      pkgs.jujutsu
    ];
  };
in
{
  programs.jujutsu = {
    enable = lib.mkDefault true;
    package = jj;
    settings = {
      user = {
        inherit (config.programs.git.iniContent.user) name email;
      };
      signing = lib.mkIf (config.programs.git.iniContent.commit.gpgSign or false) {
        sign-all = true;
        key = lib.mkIf (
          config.programs.git.iniContent.user.signingKey or null != null
        ) config.programs.git.iniContent.user.signingKey;
        backend = "gpg";
      };
      git = {
        auto-local-bookmark = false;
      };
      format = { };
      revset-aliases = {
        default_log = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
        HEAD = "@-";
        "common_ancestor(a, b)" = "heads(::a & ::b)";
        "diverge(a, b)" = "common_ancestor(a, b)::(a|b)";
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        "p(n)" = "roots(@ | ancestors(@-, n))";
        overview = "overview(common_ancestor(trunk(), git_head()))";
        "overview(base)" = "present(@) | present(base) | present(base::@) | ancestors(base:: & visible_heads(), 1)";
      };
      revsets = {
      };
      ui = {
        diff-editor = [
          (lib.getExe diffEditor)
          "-c"
          "DiffEditor $left $right $output"
        ];
        default-command = [
          "log"
          "-r"
          "overview"
        ];
      };
      templates = { };
      colors = {
        "diff added" = {
          fg = "blue";
        };
        "diff removed" = {
          fg = "red";
        };
        bookmarks = {
          bold = true;
          fg = "magenta";
        };
      };
      template-aliases = { };
      aliases = {
        l = [
          "log"
          "-r"
          ".."
        ];
        s = [
          "status"
        ];
        d = [ "diff" ];
        h = [ "help" ];
        g = [ "git" ];
        gp = [
          "git"
          "push"
        ];
        new-before = [
          "new"
          "--no-edit"
          "--before"
          "@"
        ];
        nb = [ "new-before" ];
        standup = [
          "log"
          "-r"
          ''author_date(after:"yesterday") & mine()''
          "--no-graph"
          "-T"
          "builtin_log_comfortable"
        ];
        up = [
          "rebase"
          "-b"
          "@"
          "-d"
          "trunk()"
        ];
      };
    };
  };

  # programs.nushell.extraConfig =
  #   let
  #     jjComp = pkgs.runCommandLocal "jujutsu.nu" { } ''
  #       ${
  #         lib.getExe (config.programs.nushell.package.unwrapped or config.programs.nushell.package)
  #       } -c '${lib.getExe config.programs.jujutsu.package} util completion nushell' > $out
  #     '';
  #   in
  #   lib.mkIf config.programs.jujutsu.enable ''
  #     use ${jjComp} *
  #   '';

  home.shellAliases = lib.mkIf config.programs.jujutsu.enable {
    js = "jj status";
    jd = "jj diff";
  };
}
