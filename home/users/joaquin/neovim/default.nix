{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (config.lib.impurePath) mkImpureLink;
  packages = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  mkCustomNeovim =
    pkg:
    pkg.override (prev: {
      devPluginPaths = (prev.devPluginPaths or [ ]) ++ [ (mkImpureLink ./files) ];
    });
  pureNeovim = mkCustomNeovim (
    packages.neovim.override {
      appName = "pureNvim";
      viAlias = true;
      vimAlias = false;
    }
  );
  impureNeovim =
    let
      base = mkCustomNeovim (
        packages.neovim-impure.override (prev: {
          viAlias = false;
          vimAlias = true;
          appName = "nvim";
          initLua = ''
            vim.g.usePluginsFromStore = false
            ${prev.initLua or ""}
          '';
        })
      );
    in
    pkgs.writeShellScriptBin "vim" ''
      exec -a "$0" ${lib.getExe' base "vim"} "$@"
    '';

in
{
  programs.neovim.package = pureNeovim;
  home.packages = [
    pureNeovim
    impureNeovim
  ];

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
