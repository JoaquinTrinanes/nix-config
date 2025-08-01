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
      toLua = lib.generators.toLua { };
      treesitter =
        let
          tsAllGrammars = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        in
        pkgs.symlinkJoin {
          name = "nvim-treesitter";
          paths = [ tsAllGrammars ];
          inherit (tsAllGrammars) meta passthru;
          # The JSX syntax sets `commentstring` wrong. Remove it and let ts-comments take care of it
          postBuild = ''
            query_file="$out/queries/jsx/highlights.scm"

            sed -i '/((jsx_element) @_jsx_element/,/\(#set! @_jsx_element bo.commentstring "{\/\* %s \*\/}"\))/d' "$query_file"
            sed -i '/((jsx_attribute) @_jsx_attribute/,/\(#set! @_jsx_attribute bo.commentstring "\/\/ %s"\))/d' "$query_file"
          '';
        };
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
      setPluginName = plugin: pname: plugin // { inherit pname; };
      devPlugins = builtins.attrValues {
        inherit (pkgs.vimPlugins)
          blink-cmp
          ;
        inherit bundledTreesitter;
      };
      plugins =
        devPlugins
        ++ (with pkgs.vimPlugins; [
          SchemaStore-nvim
          bufferline-nvim
          (setPluginName catppuccin-nvim "catppuccin")
          clangd_extensions-nvim
          colorful-menu-nvim
          conform-nvim
          crates-nvim
          dial-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          hardtime-nvim
          (setPluginName harpoon2 "harpoon")
          hunk-nvim
          indent-blankline-nvim
          lazy-nvim
          lazydev-nvim
          lualine-lsp-progress
          lualine-nvim
          (setPluginName luasnip "LuaSnip")
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
          nvim-navic
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
          biome
          black
          chafa
          code-minimap
          deadnix
          dockerfile-language-server-nodejs
          dotenv-linter
          fd
          fzf
          gcc
          ghostscript
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
          rust-analyzer
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
      mkPluginPathMap =
        plugins:
        let
          getPluginSpecName =
            plugin:
            plugin.pname or (
              if
                lib.hasAttrByPath [
                  "src"
                  "repo"
                ] plugin
              then
                "${plugin.src.owner}/${plugin.src.repo}"
              else
                lib.getName plugin
            );
        in
        lib.listToAttrs (map (p: lib.nameValuePair (getPluginSpecName p) p) plugins);
      extraLuaPackages = ps: [
        ps.jsregexp
        ps.magick
      ];
      mkNeovim = pkgs.callPackage ./mkNeovim.nix { };
      baseNeovim =
        let
          _self = /. + (builtins.unsafeDiscardStringContext inputs.self);
          configDir =
            (lib.fileset.toSource {
              root = _self;
              fileset = ../../home/users/joaquin/neovim/files;
            })
            + /home/users/joaquin/neovim/files;
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
          customLuaRC = ''
            require("config.lazy")
          '';
        };
    in
    {
      packages = {
        neovim = baseNeovim.override (prev: {
          customLuaRC = ''
            vim.opt.runtimepath:append(${toLua treesitterParsers})
            vim.env.LAZY = vim.env.LAZY or ${toLua pkgs.vimPlugins.lazy-nvim}
            ${prev.customLuaRC or ""}
          '';
          globals = lib.recursiveUpdate prev.globals {
            pluginPathMap = mkPluginPathMap plugins;
            nixPureMode = true;
          };
          appName = "pureNvim";
        });
        neovim-impure = baseNeovim.override (prev: {
          appName = "nvim";
          plugins = devPlugins;
          globals = prev.globals // {
            pluginPathMap = mkPluginPathMap devPlugins;
          };
        });
      };

    };
}
