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

      signing = lib.mkIf config.programs.git.signing.signByDefault {
        inherit (config.programs.git.signing) key;
        backends.gpg.program = lib.getExe pkgs.sequoia-chameleon-gnupg;
        backend =
          if (config.programs.git.signing.format == "openpgp") then
            "gpg"
          else
            config.programs.git.signing.format;
        behavior = "drop";
      };
      git = {
        auto-local-bookmark = false;
        private-commits = "private()";
        sign-on-push = config.programs.git.signing.signByDefault;
      };
      fix.tools = {
        prettier = {
          command = [
            "prettier"
            "--stdin-filepath"
            "$path"
          ];
          patterns = [
            "glob:'**/*.js'"
            "glob:'**/*.json'"
            "glob:'**/*.jsonc'"
            "glob:'**/*.jsx'"
            "glob:'**/*.md'"
            "glob:'**/*.mdx'"
            "glob:'**/*.scss'"
            "glob:'**/*.ts'"
            "glob:'**/*.tsx'"
            "glob:'**/*.vue'"
            "glob:'**/*.yaml'"
            "glob:'**/*.yml'"
          ];
        };
        biome = {
          command = [
            "biome"
            "check"
            "--stdin-file-path=$path"
            "--write"
          ];
          patterns = [
            "glob:'**/*.js'"
            "glob:'**/*.json'"
            "glob:'**/*.jsonc'"
            "glob:'**/*.jsx'"
            "glob:'**/*.md'"
            "glob:'**/*.mdx'"
            "glob:'**/*.scss'"
            "glob:'**/*.ts'"
            "glob:'**/*.tsx'"
            "glob:'**/*.vue'"
            "glob:'**/*.yaml'"
            "glob:'**/*.yml'"
          ];
        };
      };
      core = {
        # enabled per repo
        fsmonitor = "none";
        watchman.register-snapshot-trigger = true;
      };
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
        "stack(x)" = "stack(x, 2)";
        "stack(x, n)" = "original_stack(x, n)";

        # For extending in-repo config
        "original_stack(x, n)" = "ancestors(reachable(x, mutable()), n)";

        "closest_bookmarks()" = "closest_bookmarks(@)";
        "closest_bookmarks(x)" = "heads(::x & bookmarks())";

        "closest_public_bookmarks()" = "closest_public_bookmarks(@)";
        "closest_public_bookmarks(x)" = "heads(::x & bookmarks() ~ private())";

        "closest_pushable()" = "closest_pushable(@)";
        "closest_pushable(x)" =
          ''heads(reachable(closest_public_bookmarks(x), closest_public_bookmarks(x)::x ~ private() ~ description(exact:"") & (~empty() | merges())))'';

        "open()" = "stack(trunk().. & mine(), 1)";

        "why_immutable(x)" = "x | roots(x:: & immutable_heads())";
      };
      revsets = {
        log = "coalesce(stack() | trunk(), default())";
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
        always-allow-large-revsets = true;
        bookmark-list-sort-keys = [
          "author-date-"
          "committer-date-"
          "name"
        ];
        default-command = [ "log" ];
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
      templates = {
        draft_commit_description = ''
          separate(
            "\n",
            builtin_draft_commit_description,
            "JJ: ignore-rest\n\n",
            diff.git()
          )
        '';
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
        l = [
          "log"
          "-r"
          "default()"
        ];
        la = [
          "log"
          "-r"
          "::"
        ];
        ll = [
          "log"
          "-r"
          "::@"
        ];
        # jls = [
        n = [ "new" ];
        na = [
          "new"
          "--no-edit"
          "--after"
          "@"
        ];
        nb = [
          "new"
          "--no-edit"
          "--before"
          "@"
        ];
        open = [
          "log"
          "-r"
          "open() | trunk()"
        ];
        p = [
          "git"
          "push"
        ];
        r = [ "rebase" ];
        s = [ "status" ];
        sq = [ "squash" ];
        squp = [
          "squash"
          "-t"
          "@- ~ private()"
        ];
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
          "closest_public_bookmarks(@)"
          "--to"
          "closest_pushable(@)"
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

  programs.starship.settings = {
    custom = {
      jj-op = {
        when = "jj --ignore-working-copy workspace root";
        detect_folders = [ ".jj" ];
        format = ''(\[[$symbol](blue) [$output]($style)\] )'';
        symbol = "op";
        command = ''
          ls .jj/repo/op_heads/heads | head -c 4
        '';
        shell = "bash";
      };
    };
  };

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
    jna = "jj na";
    jnb = "jj nb";
    jp = "jj p";
    jr = "jj r";
    js = "jj s";
    jsq = "jj sq";
    jt = "jj t";
  };
}
