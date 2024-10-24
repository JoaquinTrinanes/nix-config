{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (config.lib.impurePath) mkImpureLink;
in
{
  programs.neovim = {
    enable = lib.mkDefault true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraPackages = builtins.attrValues {
      lazygit = config.programs.lazygit.package;
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
  xdg.configFile."nvim/ftplugin" = {
    source = ./files/ftplugin;
    recursive = true;
  };
  xdg.configFile."nvim/filetype.lua".source = mkImpureLink ./files/filetype.lua;
  xdg.configFile."nvim/after/queries/blade".source = ./files/after/queries/blade;

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
