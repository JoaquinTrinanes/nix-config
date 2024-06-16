# TODO:
# https://github.com/azuwis/lazyvim-nixvim/blob/master/flake.nix
# https://github.com/LazyVim/LazyVim/discussions/1972
# https://www.reddit.com/r/NixOS/comments/17el4x7/how_to_setup_neovim_using_lazyvim_using_nixos/
{
  lib,
  pkgs,
  inputs,
  myLib,
  ...
}:
let
  inherit (myLib) mkImpureLink;
in
{
  programs.neovim = {
    enable = lib.mkDefault true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    plugins = with pkgs.vimPlugins; [
      # telescope-fzf-native-nvim
      nvim-treesitter.withAllGrammars
    ];
    extraPackages = builtins.attrValues {
      inherit (pkgs)
        black
        deadnix
        dotenv-linter
        fd
        fzf
        gcc
        git
        gnumake
        icu
        lazygit
        lua-language-server
        marksman
        # nixd
        pyright
        ripgrep
        shellcheck
        shfmt
        statix
        stylua
        taplo
        yaml-language-server
        ;
      inherit (pkgs.nodePackages) prettier typescript-language-server;
    };
    vimAlias = true;
    viAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
    extraLuaPackages = p: [ p.jsregexp ];
  };

  xdg.configFile."nvim/lua" = {
    source = mkImpureLink ./files/lua;
    recursive = true;
  };
  xdg.configFile."nvim/lazy-lock.json".source = mkImpureLink ./files/lazy-lock.json;
  xdg.configFile."nvim/lazyvim.json".source = mkImpureLink ./files/lazyvim.json;
  xdg.configFile."nvim/ftplugin" = {
    source = ./files/ftplugin;
    recursive = true;
  };
  xdg.configFile."nvim/filetype.lua".source = mkImpureLink ./files/filetype.lua;

  xdg.configFile."tridactyl/tridactylrc".text =
    let
      ytRegex = "${lib.escapeRegex "youtube.com/watch?"}v=.*";
    in
    # vim
    ''
      " delete previously set local options
      sanitise tridactyllocal
      " sanitise commandline

      set newtab about:blank

      " set modeindicator false

      " blacklistadd ${ytRegex}
      unbindurl ${ytRegex} j
      unbindurl ${ytRegex} k
      unbindurl ${ytRegex} l
      unbindurl ${ytRegex} t
      unbindurl ${ytRegex} f
      unbindurl ${ytRegex} <Space>

      seturl ${ytRegex} modeindicator false

      " seturl localhost superignore true

      " Whether to allow pages (not necessarily github) to override /, which is a default Firefox binding.
      " set leavegithubalone true
    '';

  programs.git.ignores = [ ".lazy.lua" ];
}
