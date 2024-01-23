{
  lib,
  config,
  ...
}: {
  programs.direnv = {
    enable = true;
    stdlib = ''
      ${builtins.readFile ./lib/laravel.sh}
      ${builtins.readFile ./lib/source_parent.sh}
      ${lib.optionalString config.programs.mise.enable
        ''
          ${builtins.readFile ./lib/use_rtx.sh}
          use rtx
        ''}
      source_all_up
      dotenv_if_exists
    '';
    config = {load_dotenv = true;};
    nix-direnv.enable = true;
  };
  programs.git.ignores = [
    ".direnv"
    ".envrc"
  ];
}
