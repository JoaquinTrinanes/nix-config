{
  lib,
  config,
  ...
}:
{
  programs.direnv = {
    enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;

    nix-direnv.enable = true;

    stdlib = lib.mkMerge [
      (lib.mkIf config.programs.direnv.nix-direnv.enable (lib.mkBefore "nix_direnv_manual_reload"))
      ''
        dotenv_if_exists
      ''
    ];
    config = {
      load_dotenv = true;
      strict_env = true;
      hide_env_diff = true;
    };
  };

  xdg.configFile."direnv/lib/laravel.sh".source = ./lib/laravel.sh;
  xdg.configFile."direnv/lib/my-flake.sh".source = ./lib/my-flake.sh;
  xdg.configFile."direnv/lib/dot-direnv-outside-project.sh".source =
    ./lib/dot-direnv-outside-project.sh;

  programs.git.ignores = [
    ".direnv"
    ".envrc"
    ".devenv"
  ];
}
