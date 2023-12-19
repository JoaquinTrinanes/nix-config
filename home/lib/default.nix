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
    if (config.impurePath.enable)
    then lib.removeSuffix "/" "${config.impurePath.flakePath}/${relativePath}"
    else relativePath;
  mkImpureLink = path:
    config.lib.file.mkOutOfStoreSymlink (absPath path);
}
