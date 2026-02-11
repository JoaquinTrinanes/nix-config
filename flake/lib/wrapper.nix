{
  pkgs,
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib) mkOption types flatten;
  inherit (builtins) attrValues;

  flagsType = types.listOf (types.coercedTo types.anything (x: "${x}") types.str);

  printAndRun = cmd: ''
    echo ":: ${cmd}"
    eval "${cmd}"
  '';

  hasMan = builtins.any (builtins.hasAttr "man") ([ config.basePackage ] ++ config.extraPackages);
  envSubmodule =
    {
      config,
      lib,
      name,
      ...
    }:
    let
      inherit (lib) mkOption types;
    in
    {
      options = {
        name = mkOption {
          type = types.str;
          description = ''
            Name of the variable.
          '';
          default = name;
          example = "GIT_CONFIG";
        };

        value = mkOption {
          type =
            let
              inherit (types)
                coercedTo
                anything
                str
                nullOr
                ;
              strLike = coercedTo anything (x: "${x}") str;
            in
            nullOr strLike;
          description = ''
            Value of the variable to be set.
            Set to `null` to unset the variable.

            Note that any environment variable will be escaped. For example, `value = "$HOME"`
            will be converted to the literal `$HOME`, with its dollar sign.
          '';
          example = lib.literalExpression "./gitconfig";
        };

        force = mkOption {
          type = types.bool;
          description = ''
            Whether the value should be always set to the specified value.
            If set to `true`, the program will not inherit the value of the variable
            if it's already present in the environment.

            Setting it to false when unsetting a variable (value = null)
            will make the option have no effect.
          '';
          default = config.value == null;
          defaultText = lib.literalMD "true if `value` is null, otherwise false";
          example = true;
        };

        asFlags = mkOption {
          type = types.listOf types.str;
          internal = true;
          readOnly = true;
        };
      };

      config = {
        asFlags =
          let
            unsetArgs =
              if !config.force then
                (lib.warn ''
                  ${
                    lib.showOption [
                      "env"
                      config.name
                      "value"
                    ]
                  } is null (indicating unsetting the variable), but ${
                    lib.showOption [
                      "env"
                      config.name
                      "force"
                    ]
                  } is false. This option will have no effect
                '' [ ])
              else
                [
                  "--unset"
                  config.name
                ];
            setArgs = [
              (if config.force then "--set" else "--set-default")
              config.name
              config.value
            ];
          in
          if config.value == null then unsetArgs else setArgs;
      };
    };
in
{
  options = {

    basePackage = mkOption {
      type = types.package;
      description = "Program to be wrapped";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Optional extra packages to also wrap";
    };

    wrapped = mkOption {
      type = types.package;
      readOnly = true;
      description = "(Read-only) The final wrapped package";
    };

    overrideAttrs = mkOption {
      type = types.functionTo types.attrs;
      default = lib.id;
      defaultText = lib.literalExpression "lib.id";
      description = "Function to override attributes from the final package.";
    };

    postBuild = mkOption {
      type = types.str;
      default = "";
      description = "Raw commands to execute after wrapping has finished";
    };

    wrapFlags = mkOption {
      type = flagsType;
      default = [ ];
      description = "Structured flags passed to makeWrapper.";
    };

    appendFlags = mkOption {
      type = flagsType;
      default = [ ];
    };

    flags = mkOption {
      type = flagsType;
      default = [ ];
      description = "(Deprecated) Use prependFlags instead.";
      apply =
        flags:
        if flags == [ ] then
          [ ]
        else
          throw "The option `${lib.showOption [ "flags" ]}' used in ${lib.showFiles options.flags.files} is deprecated. Use `${
            lib.showOption [ "prependFlags" ]
          }' instead.";
    };

    prependFlags = mkOption {
      type = flagsType;
      default = [ ];
    };

    env = mkOption {
      type = types.attrsOf (types.submodule envSubmodule);
      default = { };
    };

    extraWrapperFlags = mkOption {
      type = types.separatedString " ";
      default = "";
    };

    pathAdd = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };

    wrapperType = mkOption {
      type = types.enum [
        "shell"
        "binary"
      ];
      default = "binary";
    };

    ######################################################################
    # Per-program configuration
    ######################################################################

    programs = mkOption {
      default = { };
      type = types.attrsOf (
        types.submoduleWith {
          modules = [
            (
              {
                name,
                config,
                options,
                ...
              }:
              {

                options = {

                  name = mkOption {
                    type = types.str;
                    default = name;
                  };

                  target = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };

                  wrapFlags = mkOption {
                    type = flagsType;
                    default = [ ];
                  };
                  appendFlags = mkOption {
                    type = flagsType;
                    default = [ ];
                  };
                  flags = mkOption {
                    type = flagsType;
                    default = [ ];
                    apply =
                      flags:
                      if flags == [ ] then
                        [ ]
                      else
                        throw "The option `${lib.showOption [ "flags" ]}' used in ${lib.showFiles options.flags.files} is deprecated.";
                  };
                  prependFlags = mkOption {
                    type = flagsType;
                    default = [ ];
                  };
                  env = mkOption {
                    type = types.attrsOf (types.submodule envSubmodule);
                    default = { };
                  };
                  extraWrapperFlags = mkOption {
                    type = types.separatedString " ";
                    default = "";
                  };
                  pathAdd = mkOption {
                    type = types.listOf types.package;
                    default = [ ];
                  };
                  wrapperType = mkOption {
                    type = types.enum [
                      "shell"
                      "binary"
                    ];
                    default = lib.mkDefault config.wrapperType;
                  };
                };

                config.wrapFlags =
                  (flatten (
                    map (f: [
                      "--add-flag"
                      f
                    ]) config.prependFlags
                  ))
                  ++ (flatten (
                    map (f: [
                      "--add-flag"
                      f
                    ]) config.flags
                  ))
                  ++ (flatten (
                    map (f: [
                      "--append-flag"
                      f
                    ]) config.appendFlags
                  ))
                  ++ (lib.optionals (config.pathAdd != [ ]) [
                    "--prefix"
                    "PATH"
                    ":"
                    (lib.makeBinPath config.pathAdd)
                  ])
                  ++ (flatten (map (e: e.asFlags) (attrValues config.env)));
              }
            )
          ];
        }
      );
    };
  };

  config = {
    wrapFlags =
      (flatten (
        map (f: [
          "--add-flag"
          f
        ]) config.prependFlags
      ))
      ++ (flatten (
        map (f: [
          "--add-flag"
          f
        ]) config.flags
      ))
      ++ (flatten (
        map (f: [
          "--append-flag"
          f
        ]) config.appendFlags
      ))
      ++ (lib.optionals (config.pathAdd != [ ]) [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath config.pathAdd)
      ])
      ++ (flatten (map (e: e.asFlags) (attrValues config.env)));

    wrapped =
      (
        (pkgs.symlinkJoin {
          pname = lib.getName config.basePackage;
          version = lib.getVersion config.basePackage;
          __intentionallyOverridingVersion = true;

          paths = [ config.basePackage ] ++ config.extraPackages;

          nativeBuildInputs = [
            pkgs.makeBinaryWrapper
            pkgs.makeWrapper
          ];

          passthru = (config.basePackage.passthru or { }) // {
            unwrapped = config.basePackage;
          };

          outputs = [ "out" ] ++ (lib.optional hasMan "man");

          meta = (config.basePackage.meta or { }) // {
            outputsToInstall = [ "out" ] ++ (lib.optional hasMan "man");
          };

          postBuild = ''

            pushd "$out/bin" > /dev/null

            echo "::: Wrapping explicit .programs ..."
            already_wrapped=()

            ${lib.concatMapStringsSep "\n" (
              program:
              let
                inherit (program) name;
                target = if program.target == null then "" else program.target;
                wrapProgram = if program.wrapperType == "shell" then "wrapProgramShell" else "wrapProgramBinary";
                makeWrapper = if program.wrapperType == "shell" then "makeShellWrapper" else "makeBinaryWrapper";
              in
              ''
                already_wrapped+="${name}"

                cmd=()
                if [[ -z "${target}" ]]; then
                  cmd=(${wrapProgram} "$out/bin/${name}")
                elif [[ -e "$out/bin/${name}" ]]; then
                  echo ":: Error: Target '${name}' already exists"
                  exit 1
                else
                  cmd=(${makeWrapper} "$out/bin/${target}" '${name}')
                fi

                ${
                  if program.wrapFlags == [ ] && program.extraWrapperFlags == "" then
                    "echo ':: (${name} skipped: no wrapper configuration)'"
                  else
                    printAndRun "\${cmd[@]} ${lib.escapeShellArgs program.wrapFlags} ${program.extraWrapperFlags}"
                }
              ''
            ) (attrValues config.programs)}

            echo "::: Wrapping packages in out/bin ..."

            for file in "$out/bin/"*; do
              prog="$(basename "$file")"
              if [[ " ''${already_wrapped[@]} " =~ " $prog " ]]; then
                continue
              fi

              ${
                if config.wrapFlags == [ ] && config.extraWrapperFlags == "" then
                  "echo \":: ($prog skipped: no wrapper configuration)\""
                else
                  let
                    wrapProgram = if config.wrapperType == "shell" then "wrapProgramShell" else "wrapProgramBinary";
                  in
                  printAndRun ''${wrapProgram} "$file" ${lib.escapeShellArgs config.wrapFlags} ${config.extraWrapperFlags}''
              }
            done

            popd > /dev/null

            ## Fix desktop files

            if [[ -d $out/share/applications && ! -w $out/share/applications ]]; then
              echo "Detected nested symlink, fixing"
              temp=$(mktemp -d)
              cp -v $out/share/applications/* $temp
              rm -vf $out/share/applications
              mkdir -pv $out/share/applications
              cp -v $temp/* $out/share/applications
            fi

            pushd "$out/bin" > /dev/null
            for exe in *; do
              for file in $out/share/applications/*; do
                trap "set +x" ERR
                set -x
                sed -i "s#/nix/store/.*/bin/$exe #$out/bin/$exe #" "$file"
                sed -i -E "s#Exec=$exe([[:space:]]*)#Exec=$out/bin/$exe\1#g" "$file"
                sed -i -E "s#TryExec=$exe([[:space:]]*)#TryExec=$out/bin/$exe\1#g" "$file"
                set +x
              done
            done
            popd > /dev/null

            ${lib.optionalString hasMan ''
              mkdir -p ''${!outputMan}
              ${lib.concatMapStringsSep "\n" (
                p:
                if p ? "man" then
                  "${lib.getExe pkgs.lndir} -silent ${p.man} \${!outputMan}"
                else
                  "echo \"No man output for ${lib.getName p}\""
              ) ([ config.basePackage ] ++ config.extraPackages)}
            ''}

            ${config.postBuild}
          '';
        }).overrideAttrs
        (
          final: prev: {
            name = "${final.pname}-${final.version}";
          }
        )
      ).overrideAttrs
        config.overrideAttrs;
  };
}
