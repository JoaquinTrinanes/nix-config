{
  lib,
  config,
  inputs,
  self,
  pkgs,
}:
rec {
  absPath =
    p:
    let
      path = toString p;
      strStoreDir = toString self;
      relativePath = lib.removePrefix "${strStoreDir}/" path;
    in
    if config.impurePath.enable then
      lib.removeSuffix "/" "${config.impurePath.flakePath}/${relativePath}"
    else
      relativePath;
  mkImpureLink =
    path:
    config.lib.file.mkOutOfStoreSymlink (
      if config.impurePath.enable then
        (absPath path)
      else
        lib.warn "impurePath is disabled, symlinks will point to store files" path
    );
  getPassCommand =
    key: "${lib.getExe config.programs.password-store.package} ${lib.escapeShellArg key}";
  mkWrapper =
    {
      name ? args.basePackage.name or args.basePackage.pname,
      ...
    }@args:
    let
      options = lib.attrsets.removeAttrs args [ "name" ];
      inherit (inputs) wrapper-manager;
    in
    wrapper-manager.lib.build {
      inherit pkgs;
      modules = [ { wrappers.${name} = options; } ];
    };
}
