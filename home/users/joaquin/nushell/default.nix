{
  config,
  pkgs,
  lib,
  inputs,
  myLib,
  self,
  ...
}: let
  nushellNightlyPkgs = inputs.nushell-nightly.packages.${pkgs.stdenv.hostPlatform.system};
  plugins = builtins.attrValues {
    inherit (pkgs.nushellPlugins) regex;
    inherit (nushellNightlyPkgs) nu_plugin_formats;
  };
  pluginBinFromPkg = plugin: let
    name = plugin.pname;
    matches = lib.strings.match "^nushell_plugin_(.*)" name;
  in
    if (matches == null)
    then (lib.getExe plugin)
    else "${plugin}/bin/nu_plugin_${toString matches}";
  pluginExprs = map (plugin: "register ${pluginBinFromPkg plugin}") plugins;
  pluginFile =
    pkgs.runCommandNoCCLocal "plugin.nu" {
      nativeBuildInputs = [config.programs.nushell.package];
    } ''
      touch $out
      nu --no-config-file --no-history --no-std-lib --plugin-config $out --commands '${lib.concatStringsSep ";" pluginExprs}'
    '';
in {
  imports = [
    ./theme.nix
  ];
  programs.carapace.enableNushellIntegration = false;
  programs.nushell = {
    enable = lib.mkDefault true;
    package = nushellNightlyPkgs.nushellFull;
    inherit (config.home) shellAliases;
    configFile.source = ./files/config.nu;
    envFile.source = ./files/env.nu;
    extraConfig = let
      nix = lib.getExe config.nix.package;
      formatter = lib.getExe self.formatter.${pkgs.stdenv.hostPlatform.system};
    in
      lib.mkMerge [
        ''
          # Parse text as nix expression
          def "from nix" []: string -> any {
              ${nix} eval --json --expr $in | from json
          }

          # Convert table data into a nix expression
          def "to nix" [
              --format(-f) # Format the result
          ]: any -> string {
              to json | ${nix} eval --expr $"builtins.fromJSON '''($in)'''" | if $format { ${formatter} - | ${lib.getExe pkgs.bat} --paging=never --style=plain -l nix } else { $in }
          }
        ''
        (lib.mkOrder 9999 ''
          overlay use ${./files/scripts/completions}
          # use ${./files/scripts/completions} *
        '')
      ];
  };
  programs.carapace.enable = true;
  xdg.configFile."nushell/scripts" = {
    source = myLib.mkImpureLink ./files/scripts;
    recursive = true;
  };

  xdg.configFile."nushell/plugin.nu".source = pluginFile;
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
