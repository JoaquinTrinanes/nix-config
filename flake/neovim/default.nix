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
            query_file="$out/runtime/queries/jsx/highlights.scm"

            sed -i '/((jsx_element) @_jsx_element/,/\(#set! @_jsx_element bo.commentstring "{\/\* %s \*\/}"\))/d' "$query_file"
            sed -i '/((jsx_attribute) @_jsx_attribute/,/\(#set! @_jsx_attribute bo.commentstring "\/\/ %s"\))/d' "$query_file"
          '';
        };
      treesitterParsers = pkgs.symlinkJoin {
        name = "nvim-treesitter-parsers";
        paths = treesitter.dependencies;
      };
      treesitterParsersAndQueries = pkgs.linkFarm "nvim-treesitter-bundle" {
        queries = "${treesitter}/runtime/queries";
        parser = "${treesitterParsers}/parser";
      };

      setPluginName = plugin: pname: plugin // { inherit pname; };
      devPlugins = builtins.attrValues { };
      plugins =
        devPlugins
        ++ (with pkgs.vimPlugins; [
          SchemaStore-nvim
          amp-nvim
          blink-cmp
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
          hunk-nvim
          inc-rename-nvim
          lazy-nvim
          lazydev-nvim
          lualine-nvim
          (setPluginName luasnip "LuaSnip")
          mini-ai
          mini-extra
          mini-files
          mini-icons
          mini-splitjoin
          mini-surround
          noice-nvim
          nui-nvim
          nvim-dap
          nvim-dap-go
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-lint
          nvim-lspconfig
          nvim-navic
          nvim-nio
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          render-markdown-nvim
          rustaceanvim
          smart-splits-nvim
          snacks-nvim
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
          basedpyright
          bash-language-server
          biome
          black
          dockerfile-language-server
          fd
          fzf
          gcc
          ghostscript
          git
          gnumake
          gopls
          hadolint
          icu
          imagemagick
          intelephense
          lazygit
          lua-language-server
          marksman
          netcoredbg
          nil
          nixd
          nixfmt
          nodejs
          prettier
          ripgrep
          roslyn-ls
          ruff
          rust-analyzer
          shellcheck
          shfmt
          sqlfluff
          statix
          stylua
          systemd-lsp
          tailwindcss-language-server
          taplo
          terraform-ls
          tofu-ls
          vscode-js-debug
          vscode-langservers-extracted
          vtsls
          vue-language-server
          yaml-language-server
          zls
          ;
        codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
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
              fileset = ../../home/neovim/files;
            })
            + /home/neovim/files;
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
            vue_language_server_typescript_plugin_path = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server/node_modules";
          };
          initLuaSrc = "${configDir}/init.lua";
          customLuaRC = ''
            vim.opt.runtimepath:append(${toLua treesitterParsersAndQueries})
          '';
        };
    in
    {
      packages = {
        neovim = baseNeovim.override (prev: {
          customLuaRC = ''
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
