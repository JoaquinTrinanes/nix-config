{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  myLib = import ../lib {inherit lib config;};
in {
  imports = [./direnv.nix ./theme.nix];
  programs.nushell = {
    enable = lib.mkDefault true;
    package = inputs.nushell-nightly.packages.${pkgs.stdenv.hostPlatform.system}.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./files/config.nu;
    envFile.source = ./files/env.nu;
    extraConfig = lib.mkAfter ''
      overlay use ${./files/scripts/aliases}
      overlay use ${./files/scripts/completions}
    '';

    extraEnv = let
      plugins = ["formats" "regex"];
      pluginExpr = plugin: ''
        register ${pkgs.nushellPlugins.${plugin}}/bin/nu_plugin_${plugin}
      '';
    in
      lib.concatLines (builtins.map pluginExpr plugins);
  };
  programs.carapace.enable = true;
  xdg.configFile."nushell/scripts" = {
    source = myLib.mkImpureLink ./files/scripts;
    recursive = true;
  };

  home.packages = with pkgs; [
    # for completions
    fish
  ];

  programs.bash.initExtra = lib.mkAfter ''
    if [[ ! $(ps T --no-header --format=comm | grep "^nu$") && -z $BASH_EXECUTION_STRING ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
        exec "${config.programs.nushell.package}/bin/nu" "$LOGIN_OPTION"
        fi
  '';
}
