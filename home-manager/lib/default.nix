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
    lib.removeSuffix "/" "${config.currentPath.source}/${relativePath}";
  mkImpureLink = path:
    config.lib.file.mkOutOfStoreSymlink (absPath path);
}
