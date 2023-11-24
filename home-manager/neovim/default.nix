{
  lib,
  config,
  pkgs,
  ...
}: let
  myLib = import ../lib {inherit lib config pkgs;};
  inherit (myLib) mkImpureLink;
in {
  programs.neovim = {
    enable = lib.mkDefault true;
    extraPackages = with pkgs; [gcc gnumake git];
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
  };

  xdg.configFile."nvim/lua" = {
    source = mkImpureLink ./files/lua;
    recursive = true;
  };
  xdg.configFile."nvim/neoconf.json" = {
    source = mkImpureLink ./files/neoconf.json;
  };
  xdg.configFile."nvim/lazy-lock.json" = {
    source = mkImpureLink ./files/lazy-lock.json;
  };
  xdg.configFile."nvim/lazyvim.json" = {
    source = mkImpureLink ./files/lazyvim.json;
  };
  xdg.configFile."nvim/.neoconf.json" = {
    source = ./files/.neoconf.json;
  };
  xdg.configFile."nvim/ftplugin" = {
    source = ./files/ftplugin;
    recursive = true;
  };
  xdg.configFile."nvim/filetype.lua" = {
    source = ./files/filetype.lua;
  };
}
