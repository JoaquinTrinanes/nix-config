{
  lib,
  config,
  inputs,
  self,
  pkgs,
  ...
}:
{
  _module.args.myLib = rec {
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
        basePackage,
        name ? basePackage.name or basePackage.pname,
        ...
      }@args:
      let
        options = lib.attrsets.removeAttrs args [ "name" ];
        inherit (inputs) wrapper-manager;
        wrapper = wrapper-manager.lib.build {
          inherit pkgs;
          modules = [ { wrappers.${name} = options; } ];
        };
      in
      wrapper.overrideAttrs (
        final: prev:
        lib.recursiveUpdate
          (lib.filterAttrs (
            name: value:
            lib.elem name [
              "pname"
              "name"
              "version"
              "passthru"
              "meta"
            ]
          ) basePackage)
          {
            passthru = {
              unwrapped = basePackage;
            };
            meta = {
              outputsToInstall = [ "out" ];
              outputs = [ "out" ];
            };
          }
      );
  };
}
