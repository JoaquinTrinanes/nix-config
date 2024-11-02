{
  symlinkJoin,
  lib,
  neovim-unwrapped,
  neovimUtils,

  extraLuaPackages ? _: [ ],
  extraWrapperArgs ? [ ],
  extraPackages ? [ ],
  wrapNeovimUnstable,
  configDir ? null,
  luaRcContent ? "",
  plugins ? [ ],

  packpath ? [ ],
  rtp ? [ ],

  env ? { },

# wrapRc ? true,
}:
let
  inherit (lib.generators) mkLuaInline toLua;
  pluginPath = "${neovimUtils.packDir { all.start = plugins; }}/pack/all/start";

  baseConfig = neovimUtils.makeNeovimConfig {
    inherit
      neovim-unwrapped
      extraLuaPackages
      plugins
      ;
    luaRcContent = # lua
      ''
        ${toLua { asBindings = true; } {
          "vim.opt.rtp" = [
            "${configDir}"
            (mkLuaInline "vim.env.VIMRUNTIME")
            (mkLuaInline "vim.fn.fnamemodify(vim.v.progpath, ':p:h:h') .. '/lib/nvim'")
            "${configDir}/after"
          ];
        }}
        vim.g.lazyPluginPath = ${toLua { } pluginPath}

        -- luaRcContent
        ${luaRcContent}
      '';
  };
  config = baseConfig // {
    wrapperArgs =
      baseConfig.wrapperArgs
      ++ lib.optionals (extraPackages != [ ]) [
        "--suffix"
        "PATH"
        ":"
        (lib.makeBinPath [
          (symlinkJoin {
            name = "nvim-deps";
            paths = extraPackages;
          })
        ])
      ]
      ++ lib.optionals (rtp != [ ]) [
        "--add-flags"
        "--cmd '${lib.concatMapStringsSep " | " (v: "set rtp^=${v}") rtp}'"
      ]
      ++ lib.optionals (env != { }) lib.pipe env [
        (lib.mapAttrsToList (
          name: value: [
            "--set-default"
            name
            value
          ]
        ))
        lib.flatten
      ]
      ++ lib.optionals (packpath != [ ]) [
        "--add-flags"
        "--cmd '${lib.concatMapStringsSep " | " (v: "set packpath^=${v}") rtp}'"
      ]
      ++ extraWrapperArgs;
  };
in
wrapNeovimUnstable neovim-unwrapped config
