# Function for creating a Neovim derivation
{
  pkgs,
  lib,
  # Set by the overlay to ensure we use a compatible version of `wrapNeovimUnstable`
  pkgs-wrapNeovim ? pkgs,
}:
let
  wrapper =
    {
      neovim-unwrapped ? pkgs-wrapNeovim.neovim-unwrapped,
      appName ? null,
      extraPackages ? [ ], # Extra runtime dependencies (e.g. ripgrep, ...)
      configDir ? null,
      globals ? { },
      ...
    }@allMkNeovimArgs:
    let
      restMkNeovimArgs = lib.removeAttrs allMkNeovimArgs [
        "appName"
        "configDir"
        "extraPackages"
      ];
      inherit (pkgs-wrapNeovim) neovimUtils;
      toLua = lib.generators.toLua { };
      toLuaBindings = lib.generators.toLua { asBindings = true; };
      baseConfig = neovimUtils.makeNeovimConfig restMkNeovimArgs;
      config = lib.recursiveUpdate baseConfig {
        wrapperArgs =
          baseConfig.wrapperArgs
          ++ lib.optionals (appName != null) [
            "--set-default"
            "NVIM_APPNAME"
            appName
          ]
          ++ lib.optionals (extraPackages != [ ]) [
            "--suffix"
            "PATH"
            ":"
            (lib.makeBinPath extraPackages)
          ];
        luaRcContent =
          lib.optionalString (globals != { }) (
            toLuaBindings (lib.mapAttrs' (name: value: lib.nameValuePair "vim.g.${name}" value) globals)
          )
          + lib.optionalString (configDir != null) ''
            vim.opt.runtimepath:prepend(${toLua [ (toString configDir) ]})
            vim.opt.runtimepath:append(${toLua (map (p: "${p}/after") [ (toString configDir) ])})
          ''
          + baseConfig.luaRcContent;
      };
    in
    pkgs-wrapNeovim.wrapNeovimUnstable neovim-unwrapped config;
in
lib.makeOverridable wrapper
