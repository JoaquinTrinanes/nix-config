{
  lib,
  config,
  ...
}: rec {
  absPath = p: let
    path = toString p;
    strStoreDir = toString ../..;
    relativePath = lib.removePrefix "${strStoreDir}/" path;
  in
    if config.my.impurePath.enable
    then lib.removeSuffix "/" "${config.my.impurePath.flakePath}/${relativePath}"
    else relativePath;
  mkImpureLink = path:
    config.lib.file.mkOutOfStoreSymlink (
      if config.my.impurePath.enable
      then (absPath path)
      else path
    );
  getPassCommand = key: "${lib.getExe config.programs.password-store.package} ${lib.escapeShellArg key}";
}
