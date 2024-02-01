{
  lib,
  config,
  pkgs,
  myLib,
  ...
}: let
  inherit (myLib) mkImpureLink;
  mise_activate_file =
    pkgs.runCommandNoCCLocal "use_mise.sh" {
      nativeBuildInputs = [config.programs.mise.package];
    } ''
      mise direnv activate > $out
    '';
in {
  programs.direnv = {
    enable = true;
    stdlib = ''
      ${lib.optionalString config.programs.mise.enable ''
        use mise
      ''}
      dotenv_if_exists
      source_up_if_exists
    '';
    config = {
      load_dotenv = true;
      strict_env = true;
    };
    nix-direnv.enable = true;
  };

  xdg.configFile."direnv/lib/mise.sh".source = lib.mkIf config.programs.mise.enable mise_activate_file;
  xdg.configFile."direnv/lib/laravel.sh".source = mkImpureLink ./lib/laravel.sh;
  xdg.configFile."direnv/lib/my_flake.sh".source = mkImpureLink ./lib/my_flake.sh;

  programs.git.ignores = [
    ".direnv"
    ".envrc"
    ".devenv"
  ];
}
