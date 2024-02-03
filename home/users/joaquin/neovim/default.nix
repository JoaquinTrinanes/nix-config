{
  lib,
  pkgs,
  inputs,
  myLib,
  ...
}: let
  package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  inherit (myLib) mkImpureLink;
in {
  programs.neovim = {
    inherit package;
    enable = lib.mkDefault true;
    extraPackages = with pkgs; [gcc gnumake git stylua lua-language-server fzf ripgrep];
    vimAlias = true;
    viAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
    extraLuaPackages = p: [p.jsregexp];
  };

  xdg.configFile."nvim/lua/config" = {
    source = mkImpureLink ./files/lua/config;
    recursive = true;
  };
  xdg.configFile."nvim/lua/plugins" = {
    source = mkImpureLink ./files/lua/plugins;
    recursive = true;
  };
  xdg.configFile."nvim/lua/generated.lua".text = let
    inherit (config.colors) colorScheme colorSchemeAlternate;
    mkLazySpec = {
      url,
      name,
    }: ''
      {
        ${lib.escapeShellArg url},
        ${lib.optionalString (name != null) "name = ${lib.escapeShellArg name}"}
      }
    '';
    mkColorSchemeSpec = scheme: lib.optionalString (scheme.mappings.vim.package.url != null) (mkLazySpec scheme.mappings.vim.package);
    mappings = colorScheme.mappings.vim;
    specs =
      [
        ''
          {
            "LazyVim/LazyVim",
            opts = {
              colorscheme = "${mappings.colorSchemeName}"
            },
          }
        ''
        (mkColorSchemeSpec colorScheme)
      ]
      ++ lib.optional (colorSchemeAlternate != null) (mkColorSchemeSpec colorSchemeAlternate);
  in ''
    return {
      ${lib.concatStringsSep ",\n" specs}
    }
  '';
  xdg.configFile."nvim/neoconf.json".source = mkImpureLink ./files/neoconf.json;
  xdg.configFile."nvim/lazy-lock.json".source = mkImpureLink ./files/lazy-lock.json;
  xdg.configFile."nvim/lazyvim.json".source = mkImpureLink ./files/lazyvim.json;
  xdg.configFile."nvim/.neoconf.json".source = ./files/.neoconf.json;
  xdg.configFile."nvim/ftplugin" = {
    source = ./files/ftplugin;
    recursive = true;
  };
  xdg.configFile."nvim/filetype.lua".source = mkImpureLink ./files/filetype.lua;
}
