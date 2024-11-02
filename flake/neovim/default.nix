{
  perSystem =
    {
      pkgs,
      inputs',
      lib,
      ...
    }:
    let
      neovim = pkgs.callPackage ./mkNeovim.nix {
        configDir = ../../home/users/joaquin/neovim/files;
        neovim-unwrapped = inputs'.neovim-nightly-overlay.packages.neovim;
        extraPackages = with pkgs; [
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
          pyright
          ripgrep
          shellcheck
          shfmt
          statix
          stylua
          taplo
          typescript-language-server
          yaml-language-server
        ];
        extraLuaPackages = p: [
          p.jsregexp
          p.lua-utils-nvim
        ];
        plugins = with pkgs.vimPlugins; [
          hunk-nvim
          catppuccin-nvim
          vim-dadbod
          vim-dadbod-ui
          nvim-dap-ui
          nvim-dap
          nvim-notify
          nvim-nio
          telescope-nvim
          telescope-fzf-native-nvim
          # nvim-treesitter.withAllGrammars
          lazy-nvim
          LazyVim
          nvim-treesitter-textobjects
          nvim-treesitter-context
          neo-tree-nvim
          persistence-nvim
          todo-comments-nvim
          neorg
          nvim-ts-autotag
          gitsigns-nvim
          indent-blankline-nvim
          trouble-nvim
          flash-nvim
          noice-nvim

          nvim-cmp
          cmp-buffer
          cmp-nvim-lsp
          cmp-path

          mini-ai

          rustaceanvim
          mini-indentscope
          friendly-snippets
          mini-pairs
          inc-rename-nvim
          luvit-meta
          fzf-lua
          mini-icons
          tailwindcss-colors-nvim
          SchemaStore-nvim
          neotest
          tokyonight-nvim
          cmp_luasnip

          conform-nvim
          crates-nvim
          dashboard-nvim
          lazydev-nvim
          lualine-nvim
          lualine-lsp-progress
          luasnip
          marks-nvim
          mason-lspconfig-nvim
          mason-nvim
          mini-nvim
          neo-tree-nvim
          nvim-lint
          nvim-lspconfig
          plenary-nvim
          project-nvim
          tailwindcss-colors-nvim
          ts-comments-nvim
          which-key-nvim

          bigfile-nvim
          oil-nvim
          smart-splits-nvim
          clangd_extensions-nvim
          bufferline-nvim

          (nvim-treesitter.withPlugins (
            _:
            nvim-treesitter.allGrammars
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
          ))
        ];
        env = {
          LAZY = pkgs.vimPlugins.lazy-nvim;
        };
        luaRcContent =
          let
            toLua = lib.generators.toLua { asBindings = true; };
            pluginNameOverride = {
              catppuccin = "catppuccin-nvim";
              LuaSnip = "luasnip";
            };
          in
          ''
            ${toLua { "vim.g.pluginNameOverride" = pluginNameOverride; }}
            require('config.lazy')
          '';

      };
    in
    {
      packages = {
        inherit neovim;
      };
    };
}
