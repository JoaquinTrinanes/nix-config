{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    stdlib = lib.mkMerge [
      ''
        dotenv_if_exists
        source_up_if_exists
      ''
      (lib.mkIf config.programs.direnv.nix-direnv.enable "nix_direnv_manual_reload")
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

  xdg.configFile."direnv/lib/mise.sh".source =
    let
      mise_activate_file =
        pkgs.runCommandLocal "use_mise.sh" { nativeBuildInputs = [ config.programs.mise.package ]; }
          ''
            mise direnv activate > $out
          '';
    in
    lib.mkIf config.programs.mise.enable mise_activate_file;

  xdg.configFile."direnv/lib/laravel.sh" = {
    source = ./lib/laravel.sh;
    executable = true;
  };
  xdg.configFile."direnv/lib/my-flake.sh" = {
    source = ./lib/my_flake.sh;
    executable = true;
  };
  programs.git.ignores = [
    ".direnv"
    ".envrc"
    ".devenv"
  ];
}
