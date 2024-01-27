{
  config,
  pkgs,
  lib,
  inputs,
  myLib,
  ...
}: {
  imports = [
    ./theme.nix
  ];
  programs.carapace.enableNushellIntegration = false;
  programs.nushell = {
    enable = lib.mkDefault true;
    package = inputs.nushell-nightly.packages.${pkgs.stdenv.hostPlatform.system}.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./files/config.nu;
    envFile.source = ./files/env.nu;
    extraConfig = lib.mkMerge [
      ''
        # Parse text as nix expression
        def "from nix" []: string -> any {
            ${lib.getExe config.nix.package} eval --json --expr $in | from json
        }

        # Convert table data into a nix expression
        def "to nix" [
          --format(-f) # Format the result
        ]: any -> string {
          # print (is-terminal -o)
            to json | ${lib.getExe config.nix.package} eval --expr $"builtins.fromJSON '''($in)'''" | if $format { ${lib.getExe pkgs.alejandra} -q - } else { $in }
        }
      ''
      (lib.mkOrder 9999 ''
        overlay use ${./files/scripts/completions}
        # use ${./files/scripts/completions} *
      '')
    ];

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
        exec "${lib.getExe config.programs.nushell.package}" "$LOGIN_OPTION"
        fi
  '';
}
