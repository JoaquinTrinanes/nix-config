{
  lib,
  config,
  ...
}:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    stdlib = lib.mkMerge [
      (lib.mkIf config.programs.direnv.nix-direnv.enable (lib.mkBefore "nix_direnv_manual_reload"))
      ''
        dotenv_if_exists
      ''
    ];
    config = {
      # bash_path = "";

      # disable_stdin = false;
      load_dotenv = true;

      # load with set -euo pipefail
      strict_env = true;

      # warn_timeout = "5s";

      hide_env_diff = true;

      # whitelist = {
      #   prefix = [];
      #   exact = [];
      # };
    };
  };

  xdg.configFile."direnv/lib/laravel.sh".source = ./lib/laravel.sh;
  xdg.configFile."direnv/lib/my-flake.sh".source = ./lib/my-flake.sh;

  programs.git.ignores = [
    ".direnv"
    ".envrc"
    ".devenv"
  ];
}
