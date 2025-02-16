{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  diffEditor = config.programs.neovim.package;
  jj = inputs.jj.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
    doCheck = false;
  };
in
{
  programs.jujutsu = {
    enable = lib.mkDefault true;
    package = jj;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };

      "--scope" = [
        {
          "--when" = {
            repositories = [ "~/Documents/veganhacktivists/" ];
          };
          user.email = config.accounts.email.accounts.vh.address;
        }
      ];

      signing = lib.mkIf config.programs.git.signing.signByDefault {
        inherit (config.programs.git.signing) key;
        backend =
          if (config.programs.git.signing.format == "openpgp") then
            "gpg"
          else
            config.programs.git.signing.format;
      };
      git = {
        auto-local-bookmark = false;
        private-commits = "private()";
        sign-on-push = config.programs.git.signing.signByDefault;
        subprocess = true;
      };
      core = {
        fsmonitor = "watchman";
        watchman.register_snapshot_trigger = true;
      };
      format = { };
      revset-aliases = {
        "default()" = "default(@)";
        "default(x)" = "present(x) | ancestors(immutable_heads().., 2) | present(trunk())";

        "user(x)" = "author(x) | committer(x)";

        "undescribed()" = ''description(exact:"")'';

        # useful for overriding in repo config
        "original_private()" = ''description(glob:"private:*") & mine()'';
        "private()" = "original_private()";

        "around(x)" = "around(x, 3)";
        "around(x, n)" = "ancestors(x, n) | descendants(x, n)";

        "between(x, y)" = "roots(x | y)::heads(x | y)";



        "stack()" = "stack(@)";
        "stack(from)" = "stack(from, 2)";
        "stack(from, n)" = "ancestors(reachable(@, mutable()), n)";

        "nearest_bookmarks()" = "nearest_bookmarks(@)";
        "nearest_bookmarks(x)" = "heads(::x- & bookmarks())";

        "open()" = "trunk().. & mine()";
      };
      revsets = {
        short-prefixes = "coalesce(stack(), default())";
      };
      merge-tools = {
        hunk = {
          program = lib.getExe diffEditor;
          edit-args = [
            "-n"
            "-c"
            "DiffEditor $left $right $output"
          ];
        };
      };
      ui = {
        diff-editor = "hunk";
        default-command = [
          "log"
          "-r"
          "stack() | trunk()"
        ];
      };
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
      template-aliases = {
        desc = "builtin_log_compact_full_description";
      };
      aliases = {
        a = [ "abandon" ];
        ab = [ "absorb" ];
        cat = [
          "file"
          "show"
        ];
        clone = [
          "git"
          "clone"
          "--colocate"
        ];
        d = [ "diff" ];
        dup = [ "duplicate" ];
        e = [ "edit" ];
        f = [
          "git"
          "fetch"
        ];
        g = [ "git" ];
        gp = [
          "git"
          "push"
        ];
        h = [ "help" ];
        l = [ "log" ];
        la = [
          "log"
          "-r"
          ".."
        ];
        ll = [
          "log"
          "-r"
          "::@"
        ];
        n = [ "new" ];
        new-before = [
          "new"
          "--before"
          "@"
        ];
        nb = [
          "new-before"
          "--no-edit"
        ];
        p = [
          "git"
          "push"
        ];
        s = [
          "status"
        ];
        sq = [ "squash" ];
        standup = [
          "log"
          "-r"
          ''author_date(after:"yesterday") & mine()''
          "--no-graph"
          "-T"
          "builtin_log_comfortable"
        ];
        t = [ "tug" ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "nearest_bookmarks()"
          "--to"
          ''heads(reachable(nearest_bookmarks(), nearest_bookmarks()::@ ~ description(exact:"") ~ empty() ~ private()))''
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

  home.packages = lib.mkIf config.programs.jujutsu.enable (
    builtins.attrValues { inherit (pkgs) watchman; }
  );

  programs.git.ignores = lib.mkIf config.programs.jujutsu.enable [ ".jj/" ];

  home.shellAliases = lib.mkIf config.programs.jujutsu.enable {
    j = "jj";
    ja = "jj a";
    jb = "jj b";
    jd = "jj d";
    je = "jj e";
    jf = "jj f";
    jg = "jj g";
    jl = "jj l";
    jla = "jj la";
    jll = "jj ll";
    jn = "jj n";
    jp = "jj p";
    js = "jj s";
    jt = "jj t";
  };
}
