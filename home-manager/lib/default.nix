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
    if (config.currentPath.enable)
    then lib.removeSuffix "/" "${config.currentPath.source}/${relativePath}"
    else relativePath;
  mkImpureLink = path:
    config.lib.file.mkOutOfStoreSymlink (absPath path);
}
