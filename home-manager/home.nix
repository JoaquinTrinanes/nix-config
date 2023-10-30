{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}: let
  hasGui = osConfig.services.xserver.enable;
  hasWayland = osConfig.services.xserver.displayManager.gdm.wayland;
in {
  imports = [];

  home = {
    username = "joaquin";
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${config.home.username}"
      else "/Users/${config.home.username}";
    sessionVariables = {
      # XDG_CACHE_HOME = "$HOME/.cache";
      # XDG_CONFIG_HOME = "$HOME/.config";
      # XDG_DATA_HOME = "$HOME/.local/share";
      # XDG_STATE_HOME = "$HOME/.local/state";

      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    sessionPath = [config.home.sessionVariables."XDG_BIN_HOME"];
    packages = with pkgs; [];
  };
  xdg.systemDirs.data = [
    # show desktop entries
    "$HOME/.nix-profile/share"
  ];

  # Add stuff for your user as you see fit:
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
  };
  xdg.configFile."nvim" = {
    source = ./config/nvim;
    recursive = true;
  };
  #xdg.configFile."nvim/lazy-lock.json" = {
  #  enable = false;
  #  source = config.lib.file.mkOutOfStoreSymlink ../nvim/lazy-lock.json;

  #};

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Joaquín Triñanes";
    userEmail = "hi@joaquint.io";
    extraConfig = {init = {defaultBranch = "main";};};
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
      	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
      	exec "${pkgs.nushell}/bin/nu" "$LOGIN_OPTION"
      fi
    '';
  };
  programs.nushell = {
    enable = true;
    inherit (config.home) shellAliases;
    extraConfig = ''
      $env.config = ($env.config? | default {})
      $env.config.ls = ($env.config.ls? | default {} | upsert clickable_links false)
    '';
  };

  programs.rtx.enable = true;

  programs.zoxide = {
    enable = true;
    options = ["--cmd=j"];
  };

  programs.ripgrep.enable = true;
  programs.wezterm = {
    enable = hasGui;
    extraConfig =
      ''
        local config = wezterm.config_builder()
      ''
      + lib.optionalString hasWayland ''
        config.enable_wayland = true
      ''
      + ''
        return config
      '';
  };
  programs.starship = {
    enable = true;
    settings = {
      nix_shell = {
        impure_msg = "";
        # format = "via [$symbol($state)($name)]($style) ";
      };
    };
  };

  programs.firefox = {enable = hasGui;};

  programs.direnv = {
    enable = true;
    stdlib = ''
      ### Do not edit. This was autogenerated by 'rtx direnv' ###
      use_rtx() {
        direnv_load rtx direnv exec
      }
    '';
    # TODO: set to false when custom hook is added
    # programs.direnv.enableNushellInteraction = false;
    nix-direnv.enable = true;
  };

  home.pointerCursor = {
    gtk.enable = hasGui;
    x11.enable = hasGui;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };

  # home.sessionVariables."XCURSOR_THEME" = "Bibata-Modern-Classic";

  home.shellAliases = {
    "g" = "git";
    "ll" = "ls -l";
    "la" = "ls -la";
    "hm" = "home-manager";
  };

  services.gnome-keyring.enable = true;
  services.gpg-agent.enable = true;
  services.gpg-agent.enableSshSupport = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
