{
  lib,
  config,
  self,
  ...
}: rec {
  absPath = p: let
    path = toString p;
    strStoreDir = toString self;
    relativePath = lib.removePrefix "${strStoreDir}/" path;
  in
    if config.impurePath.enable
    then lib.removeSuffix "/" "${config.impurePath.flakePath}/${relativePath}"
    else relativePath;
  mkImpureLink = path:
    config.lib.file.mkOutOfStoreSymlink (
      if config.impurePath.enable
      then (absPath path)
      else path
    );
  getPassCommand = key: "${lib.getExe config.programs.password-store.package} ${lib.escapeShellArg key}";
}
