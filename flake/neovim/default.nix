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
          plugins = with pkgs.vimPlugins; [
            catppuccin-nvim
            nvim-notify
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
          configDir = ../../home/users/joaquin/neovim/files;
          pluginPath = mkPluginPath plugins;

        in
        inputs.mnw.lib.wrap pkgs {
          neovim = inputs'.neovim-nightly-overlay.packages.default;
          initLua = ''
            ${lib.generators.toLua { asBindings = true; } {
              "vim.g.pluginPath" = pluginPath;
              "vim.g.pluginNameOverride" = {
                catppuccin = "catppuccin-nvim";
                LuaSnip = "luasnip";
                tailwindcss-colorizer-cmp = "tailwindcss-colorizer-cmp.nvim";
              };
            }}
            -- vim.opt.packpath:prepend(${lib.generators.toLua { } pluginPath})
            require("config.lazy")
          '';
          devExcludedPlugins = [ configDir ];
          devPluginPaths = [ impureConfigDir ];
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
          appName = "nvim";
          viAlias = true;
          vimAlias = true;
        });
        neovim-impure = baseNeovim.devMode.override { appName = "ivim"; };
        neovim-extra-impure =
          (baseNeovim.override (
            old:
            let
              pluginPath = mkPluginPath old.plugins;
            in
            {
              appName = "impurestNeovim";
              devExcludedPlugins = [ pluginPath ];
              plugins = [ ];
              initLua = ''require("config.lazy")'';
            }
          )).devMode;
      };

    };
}
