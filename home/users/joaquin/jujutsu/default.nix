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
        private-commits = "private_commits()";
        sign-on-push = config.programs.git.signing.signByDefault;
      };
      core = {
        fsmonitor = "watchman";
        watchman.register_snapshot_trigger = true;
      };
      format = { };
      revset-aliases = {
        "default()" = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";

        "user(x)" = "author(x) | committer(x)";

        "original_private_commits()" = ''description(glob:"private:*") & mine()'';
        "private_commits()" = "original_private_commits()";

        "around(x)" = "around(x, 3)";
        "around(x, n)" = "ancestors(x, n) | descendants(x, n)";

        "overview(from, to)" =
          "present(to::) | present(from) | present(from::to) | ancestors(from:: & (visible_heads() ~ untracked_remote_bookmarks()), 1)";

        "lagging_bookmarks" = "::bookmarks() & mutable() & mine() ~ trunk()::";

        "stack" = "stack()";
        "stack()" = "stack(@)";
        "stack(from)" = "stack(from, 2)";
        "stack(from, n)" =
          "descendants(from, 2) | ancestors(from, 2) | coalesce(ancestors(reachable(from, immutable_heads() | mutable()), n), default())";
        # TODO: this show all bookmark heads between trunk and from. Maybe don't do it and depend on the default log for that? It can get big (renovate)
        # "stack(from, n)" =
        #   "coalesce(ancestors(reachable(from, mutable() | trunk()), n) | (trunk():: & from.. & (remote_bookmarks() | bookmarks())), default())";

        "nearest_bookmarks()" = "nearest_bookmarks(@)";
        "nearest_bookmarks(x)" = "heads(::x- & bookmarks())";

        "wip()" = "wip(trunk())";
        "wip(from)" = "from::heads(mutable()) & mine()";
      };
      revsets = {
        short-prefixes = "stack() | default()";
      };
      ui = {
        diff-editor = [
          (lib.getExe diffEditor)
          "-n"
          "-c"
          "DiffEditor $left $right $output"
        ];
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
        standup = [
          "log"
          "-r"
          ''author_date(after:"yesterday") & mine()''
          "--no-graph"
          "-T"
          "builtin_log_comfortable"
        ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "nearest_bookmarks()"
          "--to"
          ''heads(reachable(nearest_bookmarks(), nearest_bookmarks()::@ ~ description(exact:"") ~ empty() ~ private_commits()))''
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
  };
}
