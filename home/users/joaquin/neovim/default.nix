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

  # vi
  pureNeovim =
    let
      base = packages.neovim.override {
        appName = "pureNvim";
        viAlias = true;
        vimAlias = false;
      };
    in
    pkgs.writeShellScriptBin "vi" ''
      exec -a "$0" ${lib.getExe base} "$@"
    '';

  # vim, nvim
  impureNeovim = packages.neovim-impure.override (prev: {
    configDir = mkImpureLink ./files;
    viAlias = false;
    vimAlias = true;
    appName = "nvim";
    globals = lib.recursiveUpdate prev.globals {
      nixPureMode = false;
      lazyOptions = {
        lockfile = mkImpureLink ./files/lazy-lock.json;
        install.missing = true;
      };
    };
  });
in
{
  programs.neovim.package = impureNeovim;
  home.sessionVariables = {
    EDITOR = config.programs.neovim.package.meta.mainProgram or "nvim";
  };

  home.packages = [
    pureNeovim
    impureNeovim
  ];

  xdg.configFile."nvim/snippets".source = mkImpureLink ./files/snippets;

  xdg.configFile."tridactyl/tridactylrc".text =
    let
      ytRegex = "${lib.escapeRegex "youtube.com/watch?"}v=.*";
      urlsToIgnore = map lib.escapeRegex [
        "figma.com"
        "discourse.nixos.org"
        "web.stremio.com"
        "https://console.hetzner.cloud/console/"
        "https://typst.app/project/"
      ];
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

      seturl ${ytRegex} modeindicator false

      unbindurl ${lib.escapeRegex "figma.com"}

      ${lib.concatLines (
        map (url: ''
          blacklistadd ${url}
          seturl ${url} modeindicator false
        '') urlsToIgnore
      )}

      seturl ^https?://localhost noiframe true
      " seturl localhost superignore true

      " Whether to allow pages (not necessarily github) to override /, which is a default Firefox binding.
      " set leavegithubalone true
    '';

  programs.git.ignores = [ ".lazy.lua" ];
}
