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
  programs.git.signing.signByDefault = lib.mkIf config.programs.jujutsu.enable (lib.mkForce false);

  programs.jujutsu = {
    enable = lib.mkDefault true;
    package = jj;
    settings = {
      user = {
        name = config.accounts.email.accounts.primary.realName;
        email = config.accounts.email.accounts.primary.address;
      };
      "--scope" = [
        {
          "--when".repositories = [ "~/Documents/cawa/" ];
          user.email = config.accounts.email.accounts.cawa.address;
        }
      ];

      signing = {
        inherit (config.programs.git.signing) key;
        backends.gpg.program = lib.getExe pkgs.sequoia-chameleon-gnupg;
        backend =
          {
            openpgp = "gpg";
            ssh = "ssh";
          }
          .${config.programs.git.signing.format} or "none";
        behavior = "drop";
      };
      git = {
        colocate = true;
        private-commits = "private()";
        sign-on-push = true;
      };
      fix.tools = {
        prettier = {
          enabled = false;
          command = [
            "prettier"
            "--stdin-filepath"
            "$path"
          ];
          patterns = [
            "glob:**/*.js"
            "glob:**/*.json"
            "glob:**/*.jsonc"
            "glob:**/*.jsx"
            "glob:**/*.md"
            "glob:**/*.mdx"
            "glob:**/*.scss"
            "glob:**/*.ts"
            "glob:**/*.tsx"
            "glob:**/*.vue"
            "glob:**/*.yaml"
            "glob:**/*.yml"
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
            "glob:**/*.js"
            "glob:**/*.json"
            "glob:**/*.jsonc"
            "glob:**/*.jsx"
            "glob:**/*.scss"
            "glob:**/*.ts"
            "glob:**/*.tsx"
            "glob:**/*.vue"
          ];
        };
        topiary-nu = {
          command = [
            "topiary"
            "format"
            "--language"
            "nu"
          ];
          patterns = [ "glob:**/*.nu" ];
        };
        nixfmt = {
          command = [
            "nixfmt"
            "--filename=$path"
          ];
          patterns = [ "glob:**/*.nix" ];
        };
        stylua = {
          command = [
            "stylua"
            "--stdin-filepath"
            "$path"
            "-"
          ];
          patterns = [ "glob:**/*.lua" ];
        };
        rustfmt = {
          command = "rustfmt";
          patterns = [ "glob:**/*.rs" ];
        };
      };
      fsmonitor = {
        backend = "none";
        watchman.register-snapshot-trigger = true;
      };
      revset-aliases = {
        "default()" = "default(@)";
        "default(x)" = "present(x) | ancestors(immutable_heads().., 2) | present(trunk())";

        "user(x)" = "author(x) | committer(x)";

        # useful for overriding in repo config
        "original_private()" =
          ''(subject(glob:"private:*") | subject(glob:"Revert \"private:*\"")) & mine()'';
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
        short-prefixes = "stack() | trunk() | heads(default())";
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
        bookmark-list-sort-keys = [
          "author-date-"
          "committer-date-"
          "name"
        ];
        default-command = [ "log" ];
        diff-editor = "hunk";
        diff-instructions = false;
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
        git_push_bookmark = ''"jt/push-" ++ change_id.short()'';
        draft_commit_description = ''
          separate(
            "\n",
            builtin_draft_commit_description,
            "JJ: ignore-rest\n",
            diff.git()
          )
        '';
      };
      template-aliases = {
        desc = "builtin_log_compact_full_description";
        "ellipsis(content, width)" = "truncate_end(width, content, '…')";
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
        ];
        conf = [
          "config"
          "edit"
          "--repo"
        ];
        d = [ "diff" ];
        dup = [ "duplicate" ];
        e = [ "edit" ];
        f = [
          "git"
          "fetch"
        ];
        gh = [
          "util"
          "exec"
          "--"
          (lib.getExe pkgs.dash)
          "-c"
          ''
            GIT_DIR="$(jj --ignore-working-copy git root)" gh "$@"
          ''
          ""
        ];
        tp = [ "tug_private" ];
        tug_private = [
          "rebase"
          "-r"
          "stack(@, 1)::@- & private()"
          "--before"
          "@"
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
        ls = [
          "file"
          "list"
        ];
        n = [ "new" ];
        nt = [
          "new"
          "trunk()"
        ];
        na = [
          "nA"
          "@"
        ];
        nA = [
          "new"
          "--no-edit"
          "--after"
        ];
        nb = [
          "nB"
          "@"
        ];
        nB = [
          "new"
          "--no-edit"
          "--before"
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
        restack = [
          "rebase"
          "-o"
          "trunk()"
          "-s"
          "roots(trunk()..stack(@))"
        ];
        retrunk = [
          "rebase"
          "-o"
          "trunk()"
        ];
        restack-all = [
          "rebase"
          "-s"
          "roots(open())"
          "-o"
          "trunk()"
        ];
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
        u = [ "undo" ];
        ws = [ "workspace" ];
        wsa = [
          "workspace"
          "add"
        ];
        wsd = [
          "workspace"
          "forget"
        ];
        # "workspace run": create a temporal workspace and run a command on it
        wsr = [
          "util"
          "exec"
          "--"
          (lib.getExe pkgs.dash)
          "-c"
          # sh
          ''
            set -euo pipefail

            REPO_NAME="$(basename "$JJ_WORKSPACE_ROOT")"
            WSDIR="$(mktemp --directory --suffix "-$REPO_NAME")"
            WSNAME="$(basename "$WSDIR")"

            trap "rm -rf $WSDIR" EXIT

            OUTPUT_FILE=$(mktemp --suffix "-$REPO_NAME-jj-output")

            jj --quiet workspace add "$WSDIR" --name "$WSNAME" --message "private: Temporal workspace $WSDIR

            Command: $@
            Output: $OUTPUT_FILE
            "

            trap "jj --quiet workspace forget $WSNAME" EXIT

            for file in .envrc .direnv .env .env.local; do
              if [ -e "$file" ]; then
                  cp -a -r "$file" "$WSDIR"
              fi
            done

            cd "$WSDIR"

            if [ -f .envrc ]; then
              direnv allow
              if command -v nix-direnv-reload >/dev/null 2>&1; then
                nix-direnv-reload
              fi
            fi

            jj --quiet config set --workspace snapshot.auto-track "all()"

            GIT_DIR="$(jj --quiet --ignore-working-copy git root)" script --quiet --log-out "$OUTPUT_FILE" --return --command "$*" 2>&1
          ''
          ""
        ];
      };
    };
  };

  home.packages = lib.mkIf config.programs.jujutsu.enable (
    builtins.attrValues { inherit (pkgs) watchman; }
  );

  programs.git.ignores = lib.mkIf config.programs.jujutsu.enable [ ".jj/" ];

  programs.starship.settings = lib.mkIf config.programs.jujutsu.enable {
    custom = {
      jj-op = {
        detect_folders = [ ".jj" ];
        format = ''(\[[$symbol](blue) [$output]($style)\] )'';
        symbol = "op";
        command = ''
          repo=.jj/repo

          # If .jj/repo is a file, read the real repo path
          [ -f "$repo" ] && IFS= read -r repo <"$repo"

          set -- "$repo"/op_heads/heads/*
          [ "$1" = "$repo/op_heads/heads/*" ] && exit 0
          printf '%.5s\n' "''${1##*/}"
        '';
        shell = lib.getExe pkgs.dash;
        description = "Current jj operation id";
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
    jnA = "jj nA";
    jnb = "jj nb";
    jnB = "jj nB";
    jp = "jj p";
    jr = "jj r";
    js = "jj s";
    jsq = "jj sq";
    jt = "jj t";
    jtp = "jj tp";
    ju = "jj u";
  };
}
