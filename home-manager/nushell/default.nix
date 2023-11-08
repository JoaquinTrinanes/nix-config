{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./direnv.nix ./theme.nix];
  programs.nushell = {
    enable = lib.mkDefault true;
    package = pkgs.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./files/config.nu;
    envFile.source = ./files/env.nu;
    extraConfig = ''
      overlay use ${./files/scripts/aliases}
      overlay use ${./files/scripts/completions}
    '';

    extraEnv = ''
      register ${pkgs.nushellPlugins.formats}/bin/nu_plugin_formats
    '';
  };
  programs.carapace.enable = true;
  xdg.configFile."nushell/scripts" = {
    source = ./files/scripts;
    recursive = true;
  };

  home.packages = with pkgs; [
    # for completions
    fish
  ];

  programs.bash.initExtra = lib.mkAfter ''
    if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
    	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
    	exec "${config.programs.nushell.package}/bin/nu" "$LOGIN_OPTION"
    fi
  '';
}
