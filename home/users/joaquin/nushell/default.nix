{
  config,
  pkgs,
  lib,
  inputs,
  myLib,
  self,
  ...
}:
let
  configDir =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/nushell"
    else
      "${config.xdg.configHome}/nushell";
  configFile = "${configDir}/config.nu";
  envFile = "${configDir}/env.nu";

  nushellPkg =
    let
      nushellNightlyPkgs = inputs.nushell-nightly.packages.${pkgs.stdenv.hostPlatform.system};
      nuUnwrapped = nushellNightlyPkgs.nushellFull;
      pluginFile =
        let
          plugins = builtins.attrValues { inherit (nushellNightlyPkgs) nu_plugin_formats; };
          pluginBinFromPkg =
            plugin:
            let
              name = plugin.pname;
              matches = lib.strings.match "^nushell_plugin_(.*)" name;
            in
            if (matches == null) then (lib.getExe plugin) else "${plugin}/bin/nu_plugin_${toString matches}";
          pluginExprs = map (plugin: "register ${pluginBinFromPkg plugin}") plugins;
        in
        pkgs.runCommandLocal "plugin.msgpackz" { nativeBuildInputs = [ nuUnwrapped ]; } ''
          touch $out {config,env}.nu
          nu --config config.nu \
          --env-config env.nu \
          --plugin-config plugin.msgpackz \
          --no-history \
          --no-std-lib \
          --commands '${lib.concatStringsSep ";" pluginExprs};'
          cp plugin.msgpackz $out
        '';
    in
    myLib.mkWrapper {
      basePackage = nuUnwrapped;
      flags = [
        "--plugin-config"
        pluginFile
        "--config"
        config.home.file."${configFile}".source
        "--env-config"
        config.home.file."${envFile}".source
      ];
    };
  scriptsDir = myLib.mkImpureLink ./files/scripts;
in
{
  imports = [ ./theme.nix ];
  programs.carapace.enableNushellIntegration = false;

  # config file are added to the wrapper
  home.file."${configFile}".enable = false;
  home.file."${envFile}".enable = false;

  programs.nushell = {
    enable = lib.mkDefault true;
    package = nushellPkg;
    inherit (config.home) shellAliases;

    # TODO: this causes IFD because the nushell module reads the source
    configFile.source = pkgs.substituteAll {
      src = ./files/config.nu;
      fish = lib.getExe pkgs.fish;
    };
    environmentVariables = {
      "NU_LIB_DIRS" = toString scriptsDir;
    };
    envFile.source = ./files/env.nu;
    extraConfig =
      let
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
          use ${scriptsDir} *
          overlay use ${scriptsDir}/completions
        '')
      ];
  };

  # just before mkAfter, so we can skip unneeded bash interactive initialization
  programs.bash.initExtra = lib.mkOrder 1499 ''
    if [[ ! $(ps T --no-header --format=comm | grep -E -- '^(nu|.nu-wrapped)$') && -z $BASH_EXECUTION_STRING ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
        exec "${lib.getExe config.programs.nushell.package}" "$LOGIN_OPTION"
    fi
  '';
}
