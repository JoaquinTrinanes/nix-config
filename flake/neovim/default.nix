{
  perSystem =
    {
      pkgs,
      inputs',
      lib,
      ...
    }:
    let
      toLua = lib.generators.toLua { };
      mkPluginPath =
        plugins:
        let
          mkEntryFromDrv =
            drv:
            if lib.isDerivation drv then
              {
                name = lib.getName drv;
                path = drv;
              }
            else
              drv;
        in
        pkgs.linkFarm "vim-plugin-path" (map mkEntryFromDrv plugins);
      treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
        _:
        pkgs.vimPlugins.nvim-treesitter.allGrammars
        ++ [
          (pkgs.tree-sitter.buildGrammar {
            language = "blade";
            version = "0.10.1";
            src = pkgs.fetchFromGitHub {
              owner = "EmranMR";
              repo = "tree-sitter-blade";
              rev = "335b2a44b4cdd9446f1c01434226267a61851405";
              hash = "sha256-wXzmlg79Xva08wn3NoJDJ2cIHuShXPIlf+UK0TsZdbY=";
            };
          })
        ]
      );
      treesitterParsers = pkgs.symlinkJoin {
        name = "nvim-treesitter-parsers";
        paths = treesitter.dependencies;
      };
      bundledTreesitter = pkgs.symlinkJoin {
        name = "nvim-treesitter";
        paths = [
          treesitter
          treesitterParsers
        ];
      };
      plugins =
        [
          bundledTreesitter
        ]
        ++ (with pkgs.vimPlugins; [
          bigfile-nvim
          bufferline-nvim
          catppuccin-nvim
          clangd_extensions-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          conform-nvim
          fidget-nvim
          crates-nvim
          dashboard-nvim
          dial-nvim
          dressing-nvim
          flash-nvim
          flatten-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          hardtime-nvim
          harpoon2
          hunk-nvim
          indent-blankline-nvim
          lazy-nvim
          lazydev-nvim
          lualine-lsp-progress
          lualine-nvim
          luasnip
          marks-nvim
          mason-lspconfig-nvim
          mason-nvim
          mini-ai
          mini-hipatterns
          mini-icons
          mini-indentscope
          mini-nvim
          neo-tree-nvim
          neorg
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-dap
          nvim-dap-ui
          nvim-lint
          nvim-lspconfig
          nvim-nio
          nvim-snippets
          nvim-treesitter-context
          SchemaStore-nvim
          nvim-treesitter-textobjects
          nvim-ts-autotag
          oil-nvim
          persistence-nvim
          plenary-nvim
          project-nvim
          render-markdown-nvim
          rustaceanvim
          smart-splits-nvim
          snacks-nvim
          tailwindcss-colors-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          trouble-nvim
          ts-comments-nvim
          vim-dadbod
          vim-dadbod-completion
          vim-dadbod-ui
          vim-jjdescription
          which-key-nvim
        ]);
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          black
          chafa
          deadnix
          dotenv-linter
          fd
          fzf
          gcc
          git
          gnumake
          icu
          intelephense
          lazygit
          lua-language-server
          marksman
          nil
          nixd
          nodejs
          phpactor
          pyright
          ripgrep
          shellcheck
          shfmt
          statix
          stylua
          taplo
          typescript-language-server
          vscode-langservers-extracted
          yaml-language-server
          ;
        inherit (pkgs.nodePackages) prettier;
      };
      pluginNameOverride = {
        catppuccin = "catppuccin-nvim";
        LuaSnip = "luasnip";
        tailwindcss-colorizer-cmp = "tailwindcss-colorizer-cmp.nvim";
        harpoon = "harpoon2";
      };
      devPlugins = builtins.attrValues { inherit (pkgs.vimPlugins) blink-cmp telescope-fzf-native-nvim; };
      mkPluginPathMap =
        plugins:
        let
          getPluginSpecName =
            plugin:
            let
              name = plugin.pname or plugin.name;
            in
            if lib.hasAttr name pluginNameOverride then
              pluginNameOverride.${name}
            else if
              lib.hasAttrByPath [
                "src"
                "repo"
              ] plugin
            then
              "${plugin.src.owner}/${plugin.src.repo}"
            else
              name;
        in
        lib.listToAttrs (map (p: lib.nameValuePair (getPluginSpecName p) p) plugins);
      extraLuaPackages = ps: [ ps.jsregexp ];
      mkNeovim = pkgs.callPackage ./mkNeovim.nix { };
      baseNeovim =
        let
          pluginPath = mkPluginPath plugins;
          configDir = ../../home/users/joaquin/neovim/files;
        in
        mkNeovim {
          neovim-unwrapped = inputs'.neovim-nightly-overlay.packages.default;
          inherit
            plugins
            extraLuaPackages
            extraPackages
            configDir
            ;
          globals = {
            inherit pluginPath;
            lazyOptions = {
              lockfile = "${configDir}/lazy-lock.json";
              install.missing = false;
            };
          };
          luaRcContent = ''
            require("config.lazy")
          '';
        };
    in
    {
      packages = {
        neovim = baseNeovim.override (prev: {
          luaRcContent =
            ''
              vim.env.LAZY = vim.env.LAZY or ${toLua pkgs.vimPlugins.lazy-nvim}
            ''
            + prev.luaRcContent or "";
          globals = lib.recursiveUpdate prev.globals {
            pluginPathMap = mkPluginPathMap plugins;
            usePluginsFromStore = true;
          };
          appName = "pureNvim";
        });
        neovim-impure = baseNeovim.override (prev: {
          appName = "nvim";
          globals = prev.globals // {
            pluginPathMap = mkPluginPathMap devPlugins;
          };
          luaRcContent = ''
            vim.opt.runtimepath:append(${toLua treesitterParsers})
            vim.go.packpath = vim.env.VIMRUNTIME
            ${prev.luaRcContent or ""}
          '';
        });
      };

    };
}
