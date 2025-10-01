{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (config.lib.impurePath) mkImpureLink;
  configDir =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/nushell"
    else
      "${config.xdg.configHome}/nushell";
  configFile = "${configDir}/config.nu";
  envFile = "${configDir}/env.nu";
  pluginFile = "${configDir}/plugin.msgpackz";
  nushellNightlyPkgs = inputs.nushell-nightly.packages.${pkgs.stdenv.hostPlatform.system};
  inherit (nushellNightlyPkgs) nushell;

  nushellWrapped =
    let
      customPluginFile =
        let
          pluginExprs = map (plugin: "plugin add ${lib.getExe plugin}") config.programs.nushell.plugins;
        in
        pkgs.runCommandLocal "plugin.msgpackz" { nativeBuildInputs = [ nushell ]; } ''
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
    pkgs.my.mkWrapper {
      basePackage = nushell;
      prependFlags =
        let
          envFileSource = builtins.tryEval config.home.file."${envFile}".source;
          configFileSource = builtins.tryEval config.home.file."${configFile}".source;
        in
        [
          "--plugin-config"
          customPluginFile
        ]
        ++ lib.optionals configFileSource.success [
          "--config"
          configFileSource.value
        ]
        ++ lib.optionals envFileSource.success [
          "--env-config"
          envFileSource.value
        ];
      pathAdd = [ pkgs.fish ];
    };
in
{
  # config files are added to the wrapper
  home.file."${configFile}".enable = false;
  home.file."${envFile}".enable = false;
  home.file."${pluginFile}".enable = false;

  programs.nushell = {
    enable = lib.mkDefault true;
    package = nushellWrapped;

    shellAliases = {
      fg = "job unfreeze";
    };

    plugins = builtins.attrValues {
      inherit (nushellNightlyPkgs)
        nu_plugin_formats
        nu_plugin_polars
        ;
    };

    # Source the file instead of setting the source to avoid HM causing IFD
    configFile.text = ''
      source ${mkImpureLink ./files/config.nu}
    '';
    extraConfig =
      let
        nix = if config.nix.package == null then pkgs.nix else lib.getExe config.nix.package;
        # formatter = lib.getExe inputs.self.formatter.${pkgs.stdenv.hostPlatform.system};
        formatter = lib.getExe pkgs.nixfmt;
      in
      lib.mkMerge [
        # nu
        ''
          # Parse text as nix expression
          def "from nix" []: string -> any {
              ${nix} eval --json -f - | from json
          }

          # Convert table data into a nix expression
          def "to nix" [
              --format(-f) # Format the result
          ]: any -> string {
              to json --raw
              | str replace --all "''$" $"(char single_quote)(char single_quote)$"
              | nix eval --expr $"builtins.fromJSON '''($in)'''"
              | if $format { ${formatter} - | ${lib.getExe pkgs.bat} --paging=never --style=plain -l nix } else { $in }
          }
        ''
        (
          let
            scriptsDir = mkImpureLink ./files/scripts;
          in
          lib.mkOrder 9999 ''
            use ${scriptsDir} *
            overlay use ${scriptsDir}/completions
          ''
        )
      ];
  };

  programs.bash.initExtra = lib.mkBefore ''
    if [[ ! $(ps T --no-header --format=comm | grep -E -- '^(nu|.nu-wrapped)$') && -z $BASH_EXECUTION_STRING ]]; then
        LOGIN_OPTIONS=()
        if shopt -q login_shell; then
          LOGIN_OPTIONS+=('--login') 
        fi
        # if nu errors, don't lock out of bash
        if SHLVL="$((SHLVL - 1))" ${lib.getExe config.programs.nushell.package} "''${LOGIN_OPTIONS[@]}"; then
          exit 0
        fi
    fi
  '';
}
