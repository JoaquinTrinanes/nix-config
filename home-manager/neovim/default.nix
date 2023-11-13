{
  lib,
  config,
  ...
}: let
  myLib = import ../lib {inherit lib config;};
  inherit (myLib) mkImpureLink;
in {
  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
  };

  xdg.configFile."nvim/lua" = {
    source = myLib.mkImpureLink ./files/lua;
    recursive = true;
  };
  xdg.configFile."nvim/neoconf.json" = {
    source = mkImpureLink ./files/neoconf.json;
  };
  xdg.configFile."nvim/.neoconf.json" = {
    source = mkImpureLink ./files/.neoconf.json;
  };
  xdg.configFile."nvim/lazy-lock.json" = {
    source = mkImpureLink ./files/lazy-lock.json;
  };
  xdg.configFile."nvim/lazyvim.json" = {
    source = mkImpureLink ./files/lazyvim.json;
  };
  xdg.configFile."nvim/ftplugin" = {
    source = ./files/lazyvim.json;
    recursive = true;
  };
}
