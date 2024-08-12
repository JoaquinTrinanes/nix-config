let
  mkLib =
    { pkgs, lib }:
    {
      # Adapted from https://github.com/viperML/wrapper-manager/blob/e1584a27f947c5a5d208c06ffcce09f13a3bd9a9/modules/base.nix
      mkWrapper =
        {
          basePackage,
          extraPackages ? [ ],
          env ? { },
          flags ? [ ],
          prependFlags ? [ ],
          appendFlags ? [ ],
          pathAdd ? [ ],
          extraWrapperFlags ? [ ],
          renames ? { },
          binaryWrapper ? false,
        }:
        let
          wrapped =
            let
              envToWrapperArg =
                name:
                {
                  value,
                  force ? value == null,
                }:
                let
                  optionStr =
                    attr:
                    lib.showOption [
                      "env"
                      name
                      attr
                    ];
                  unsetArg =
                    if !force then
                      (lib.warn ''
                        ${optionStr "value"} is null (indicating unsetting the variable), but ${optionStr "force"} is false. This option will have no effect
                      '' [ ])
                    else
                      [
                        "--unset"
                        name
                      ];
                  setArg =
                    let
                      arg = if force then "--set" else "--set-default";
                    in
                    [
                      arg
                      name
                      value
                    ];
                in
                if value == null then unsetArg else setArg;
              result =
                pkgs.symlinkJoin (
                  {
                    paths = [ basePackage ] ++ extraPackages;
                    nativeBuildInputs = if binaryWrapper then [ pkgs.makeBinaryWrapper ] else [ pkgs.makeWrapper ];
                    postBuild =
                      let
                        envArgs = lib.mapAttrsToList envToWrapperArg env;
                        # Yes, the arguments are escaped later, yes, this is intended to "double escape",
                        # so that they are escaped for wrapProgram and for the final binary too.
                        prependFlagArgs = map (args: [
                          "--add-flags"
                          (lib.escapeShellArg args)
                        ]) prependFlags;
                        appendFlagArgs = map (args: [
                          "--append-flags"
                          (lib.escapeShellArg args)
                        ]) (appendFlags ++ flags);
                        pathArgs = map (p: [
                          "--prefix"
                          "PATH"
                          ":"
                          "${p}/bin"
                        ]) pathAdd;
                        allArgs = lib.flatten (envArgs ++ prependFlagArgs ++ appendFlagArgs ++ pathArgs);
                      in
                      ''
                        for file in $out/bin/*; do
                          echo "Wrapping $file"
                          wrapProgram \
                            $file \
                            ${lib.escapeShellArgs allArgs} \
                            ${toString extraWrapperFlags}
                        done

                        # Some derivations have nested symlinks here
                        if [[ -d $out/share/applications && ! -w $out/share/applications ]]; then
                          echo "Detected nested symlink, fixing"
                          temp=$(mktemp -d)
                          cp -v $out/share/applications/* $temp
                          rm -vf $out/share/applications
                          mkdir -pv $out/share/applications
                          cp -v $temp/* $out/share/applications
                        fi

                        cd $out/bin
                        for exe in *; do

                          if false; then
                            exit 2
                          ${
                            lib.concatStringsSep "\n" (
                              lib.mapAttrsToList (name: value: ''
                                elif [[ $exe == ${lib.escapeShellArg name} ]]; then
                                  newexe=${lib.escapeShellArg value}
                                  mv -vf $exe $newexe
                              '') renames
                            )
                          }
                          else
                            newexe=$exe
                          fi

                          # Fix .desktop files
                          # This list of fixes might not be exhaustive
                          for file in $out/share/applications/*; do
                            echo "Fixing file=$file for exe=$exe"
                            set -x
                            trap "set +x" ERR
                            sed -i "s#/nix/store/.*/bin/$exe #$out/bin/$newexe #" "$file"
                            sed -i -E "s#Exec=$exe([[:space:]]*)#Exec=$out/bin/$newexe\1#g" "$file"
                            sed -i -E "s#TryExec=$exe([[:space:]]*)#TryExec=$out/bin/$newexe\1#g" "$file"
                            set +x
                          done
                        done


                        # I don't know of a better way to create a multe-output derivation for symlinkJoin
                        # So if the packages have man, just link them into $out
                        ${lib.concatMapStringsSep "\n" (
                          p: if lib.hasAttr "man" p then "${lib.getExe pkgs.xorg.lndir} -silent ${p.man} $out" else "#"
                        ) ([ basePackage ] ++ extraPackages)}
                      '';
                    passthru = (basePackage.passthru or { }) // {
                      unwrapped = basePackage;
                    };
                  }
                  // lib.getAttrs [
                    "name"
                    "meta"
                  ] basePackage
                )
                // (lib.optionalAttrs (lib.hasAttr "pname" basePackage) { inherit (basePackage) pname; })
                // (lib.optionalAttrs (lib.hasAttr "version" basePackage) { inherit (basePackage) version; });
            in
            lib.recursiveUpdate result { meta.outputsToInstall = [ "out" ]; };
        in
        wrapped;
    };
in
{
  perSystem =
    { pkgs, lib, ... }:
    {
      _module.args.lib = lib.extend (
        final: _prev: {
          my = mkLib {
            inherit pkgs;
            lib = final;
          };
        }
      );
    };
}
