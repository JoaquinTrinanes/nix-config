{
  lib,
  config,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    stdlib = ''
      dotenv_if_exists
      source_up_if_exists
    '';
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
    nix-direnv.enable = true;
  };

  xdg.configFile."direnv/lib/mise.sh".source = let
    mise_activate_file =
      pkgs.runCommandNoCCLocal "use_mise.sh" {
        nativeBuildInputs = [config.programs.mise.package];
      } ''
        mise direnv activate > $out
      '';
  in
    lib.mkIf config.programs.mise.enable mise_activate_file;

  xdg.configFile."direnv/lib/laravel.sh".source = ./lib/laravel.sh;
  xdg.configFile."direnv/lib/my_flake.sh".source = ./lib/my_flake.sh;

  programs.git.ignores = [
    ".direnv"
    ".envrc"
    ".devenv"
  ];
}
