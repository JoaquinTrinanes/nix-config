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
      devPlugins = builtins.attrValues {
        inherit (pkgs.vimPlugins)
          blink-cmp
          ;
      };
      plugins =
        devPlugins
        ++ [
          bundledTreesitter
        ]
        ++ (with pkgs.vimPlugins; [
          LazyVim
          SchemaStore-nvim
          bufferline-nvim
          catppuccin-nvim
          clangd_extensions-nvim
          conform-nvim
          crates-nvim
          dial-nvim
          flash-nvim
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
          mini-files
          mini-hipatterns
          mini-icons
          mini-indentscope
          mini-nvim
          mini-splitjoin
          mini-surround
          minimap-vim
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-dap
          nvim-dap-ui
          nvim-lint
          nvim-lspconfig
          nvim-nio
          nvim-snippets
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-web-devicons
          oil-nvim
          persistence-nvim
          plenary-nvim
          project-nvim
          render-markdown-nvim
          rustaceanvim
          snacks-nvim
          tailwindcss-colors-nvim
          todo-comments-nvim
          trouble-nvim
          ts-comments-nvim
          vim-dadbod
          vim-dadbod-completion
          vim-dadbod-ui
          vim-sleuth
          which-key-nvim
        ]);
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          bash-language-server
          black
          chafa
          code-minimap
          deadnix
          dockerfile-language-server-nodejs
          dotenv-linter
          fd
          fzf
          gcc
          git
          gnumake
          icu
          imagemagick
          intelephense
          lazygit
          lua-language-server
          marksman
          nil
          nixd
          nodejs
          prettier
          pyright
          ripgrep
          ruff
          shellcheck
          shfmt
          sqlfluff
          statix
          stylua
          tailwindcss-language-server
          taplo
          typescript-language-server
          vscode-langservers-extracted
          vtsls
          yaml-language-server
          ;
      };
      pluginNameOverride = {
        catppuccin-nvim = "catppuccin";
        LuaSnip = "luasnip";
        tailwindcss-colorizer-cmp = "tailwindcss-colorizer-cmp.nvim";
        harpoon = "harpoon2";
      };
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
      extraLuaPackages = ps: [
        ps.jsregexp
        ps.magick
      ];
      mkNeovim = pkgs.callPackage ./mkNeovim.nix { };
      baseNeovim' =
        let
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
            lazyOptions = {
              lockfile = "${configDir}/lazy-lock.json";
              install.missing = false;
            };
          };
          luaRcContent = ''
            require("config.lazy")
          '';
        };
      baseNeovim = baseNeovim'.overrideAttrs { dontRewriteSymlinks = true; };
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
