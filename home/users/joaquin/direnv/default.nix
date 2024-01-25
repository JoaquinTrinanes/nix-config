{
  lib,
  config,
  pkgs,
  ...
}: let
  mise_activate_file = pkgs.runCommandNoCCLocal "use_mise.sh" {nativeBuildInputs = [pkgs.mise];} ''
    mise direnv activate > $out
  '';
in {
  programs.direnv = {
    enable = true;
    stdlib = ''
      ${builtins.readFile ./lib/laravel.sh}
      ${builtins.readFile ./lib/source_parent.sh}
      ${lib.optionalString (false && config.programs.mise.enable)
        ''
          ${builtins.readFile mise_activate_file}
          use mise
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
