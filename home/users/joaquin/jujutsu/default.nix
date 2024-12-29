{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  diffEditor = config.programs.neovim.package;
  jj-unwrapped = inputs.jj.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
    doCheck = false;
  };

  jj = lib.my.mkWrapper {
    basePackage = jj-unwrapped;

    extraPackages = [
      (pkgs.writeTextDir "share/fish/vendor_completions.d/jj.fish" ''
        function __jj
          command jj --ignore-working-copy --color=never --quiet $argv 2> /dev/null
        end
        COMPLETE=fish __jj | source
      '')
      jj-unwrapped
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

      "--scope" = [
        {
          "--when" = {
            repositories = [ "~/Documents/veganhacktivists/" ];
          };
          user.email = config.accounts.email.accounts.vh.address;
        }
      ];

      signing = lib.mkIf (config.programs.git.iniContent.commit.gpgSign or false) {
        sign-all = true;
        key = lib.mkIf (
          config.programs.git.iniContent.user.signingKey or null != null
        ) config.programs.git.iniContent.user.signingKey;
        backend = "gpg";
      };
      git = {
        auto-local-bookmark = false;
        private-commits = "private_commits()";
      };
      core = {
        fsmonitor = "watchman";
        watchman.register_snapshot_trigger = true;
      };
      format = { };
      revset-aliases = {
        default = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
        "private_commits()" = ''description("private:*") & mine()'';
        "diverge(x)" = "fork_point(x)::x";
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";

        # get last n ancestor of rev
        "p(base, n)" = "roots(base | ancestors(base-, n))";
        "p(n)" = "p(@, n)";

        "overview(from, to)" =
          "present(to::) | present(from) | present(from::to) | ancestors(from:: & (visible_heads() ~ untracked_remote_bookmarks()), 1)";
        "overview(from)" = "overview(from, @)";
        overview = "overview(fork_point(trunk() | git_head()))";

        "lagging_bookmarks" = "::bookmarks() & mutable() & mine() ~ trunk()::";

        # Current stack of commits
        "current(from, n)" = "coalesce(ancestors(reachable(from, mutable()), n), default)";
        "current(from)" = "current(from, 2)";
        current = "current(@-+)";

        "nearest_bookmarks(from)" = "heads(::from- & bookmarks())";
        "nearest_bookmarks()" = "nearest_bookmarks(@)";

        wip = "trunk()::heads(mutable()) & mine()";
      };
      revsets = {
        short-prefixes = "current | default";
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
          "current | trunk()"
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
      template-aliases = {
        desc = "builtin_log_compact_full_description";
      };
      aliases = {
        a = [ "abandon" ];
        ab = [ "absorb" ];
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
          ''heads(ancestors(@) & description(regex:".") ~ empty())''
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
