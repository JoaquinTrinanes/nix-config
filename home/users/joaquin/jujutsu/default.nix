{
  config,
  lib,
  ...
}:
{
  programs.jujutsu = {
    enable = lib.mkDefault true;
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
        auto-local-bookmark = true;
      };
      format = { };
      ui = {
        default-command = [
          "log"
          # "status"
          # "--no-pager"
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
      };
      template-aliases = { };
      aliases = {
        l = [
          "log"
          "-r"
          "(HEAD@git..@):: | (HEAD@git..@)-"
        ];
        s = [
          "status"
          "--no-pager"
        ];
        d = [ "diff" ];
        h = [ "help" ];
        gp = [
          "git"
          "push"
        ];
      };
      revset-aliases = {
        HEAD = "@-";
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
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
    jjs = "jj status";
    js = "jj status";
    jd = "jj diff";
  };
}
