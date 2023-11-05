{lib, ...}: {
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
    source = ./files/lua; # config.lib.file.mkOutOfStoreSymlink ./config/nushell;
    recursive = true;
  };
}
