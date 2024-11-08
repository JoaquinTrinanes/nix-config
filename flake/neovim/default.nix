{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
      lib,
      ...
    }:
    let
      toLuaBindings = lib.generators.toLua { asBindings = true; };
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

      baseNeovim =
        let
          treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
            _:
            pkgs.vimPlugins.nvim-treesitter.allGrammars
            ++ [
              pkgs.tree-sitter-grammars.tree-sitter-nu
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
          plugins =
            [ treesitter ]
            ++ (with pkgs.vimPlugins; [
              bigfile-nvim
              bufferline-nvim
              catppuccin-nvim
              clangd_extensions-nvim
              cmp-buffer
              cmp-nvim-lsp
              cmp-path
              conform-nvim
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
              LazyVim
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
              nvim-treesitter-textobjects
              nvim-ts-autotag
              oil-nvim
              persistence-nvim
              plenary-nvim
              project-nvim
              render-markdown-nvim
              rustaceanvim
              SchemaStore-nvim
              smart-splits-nvim
              tailwindcss-colors-nvim
              telescope-fzf-native-nvim
              telescope-nvim
              todo-comments-nvim
              treesitter
              trouble-nvim
              ts-comments-nvim
              vim-dadbod
              vim-dadbod-completion
              vim-dadbod-ui
              vim-jjdescription
              which-key-nvim
            ]);
          configDir = ../../home/users/joaquin/neovim/files;
          pluginPath = mkPluginPath plugins;
        in
        inputs.mnw.lib.wrap pkgs {
          neovim = inputs'.neovim-nightly-overlay.packages.default;
          initLua = ''
            ${toLuaBindings {
              "vim.g.pluginPath" = pluginPath;
              "vim.g.pluginNameOverride" = {
                catppuccin = "catppuccin-nvim";
                LuaSnip = "luasnip";
                tailwindcss-colorizer-cmp = "tailwindcss-colorizer-cmp.nvim";
                harpoon = "harpoon2";
              };
            }}
            -- vim.opt.runtimepath:append(${lib.generators.toLua { } pluginPath})
            -- vim.opt.packpath:prepend(${lib.generators.toLua { } pluginPath})
            require("config.lazy")
          '';
          devExcludedPlugins = [ configDir ];
          devPluginPaths = [ ];
          inherit plugins;
          extraBinPath = builtins.attrValues {
            inherit (pkgs)
              lazygit
              black
              deadnix
              dotenv-linter
              fd
              fzf
              gcc
              git
              gnumake
              icu
              intelephense
              lua-language-server
              marksman
              nil
              nixd
              nodejs
              pyright
              ripgrep
              shellcheck
              shfmt
              statix
              stylua
              taplo
              typescript-language-server
              yaml-language-server
              ;
            inherit (pkgs.nodePackages) prettier;
          };
          extraLuaPackages = ps: [ ps.jsregexp ];
        };
    in
    {
      packages = {
        neovim = baseNeovim.override (prev: {
          initLua = ''
            vim.env.LAZY = vim.env.LAZY or "${pkgs.vimPlugins.lazy-nvim}"
            ${prev.initLua or ""}
          '';
          appName = "pureNvim";
          viAlias = true;
          vimAlias = true;
        });
        neovim-impure =
          (baseNeovim.override (prev: {
            appName = "nvim";
            initLua = ''
              ${toLuaBindings { "vim.g.usePluginsFromStore" = false; }}
              vim.go.packpath = vim.env.VIMRUNTIME
              ${prev.initLua or ""}
            '';
          })).devMode;
      };

    };
}
