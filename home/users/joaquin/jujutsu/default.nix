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
        source ${jj-unwrapped}/share/fish/vendor_completions.d/jj.fish
        source ${./jj.fish}
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
        default_log = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
        "private_commits()" = ''description("private:*") & mine()'';
        "diverge(x)" = "fork_point(x)::x";
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";

        # get last n ancestors of rev
        "p(base, n)" = "roots(base | ancestors(base-, n))";
        "p(n)" = "p(@, n)";

        "overview(from, to)" =
          "present(to::) | present(from) | present(from::to) | ancestors(from:: & (visible_heads() ~ untracked_remote_bookmarks()), 1)";
        "overview(from)" = "overview(from, @)";
        overview = "overview(fork_point(trunk() | git_head()))";
      };
      revsets = {
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
      template-aliases = {
        desc = "builtin_log_compact_full_description";
      };
      aliases = {
        a = [ "abandon" ];
        ab = [ "abandon" ];
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
        f = [
          "git"
          "fetch"
        ];
        gp = [
          "git"
          "push"
        ];
        clone = [
          "git"
          "clone"
          "--colocate"
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
    jb = "jj bookmark";
    jd = "jj diff";
    jf = "jj git fetch";
    jg = "jj git";
    jl = "jj log";
    jn = "jj new";
    jp = "jj git push";
    js = "jj status";
  };
}
