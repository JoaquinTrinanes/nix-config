# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # If you want to use overlays exported from other flakes:
  #     # neovim-nightly-overlay.overlays.default
  #
  #     # Or define it inline, for example:
  #     # (final: prev: {
  #     #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     #     patches = [ ./change-hello-to-hi.patch ];
  #     #   });
  #     # })
  #   ];
  #   # Configure your nixpkgs instance
  #   config = {
  #     # Disable if you don't want unfree packages
  #     allowUnfree = true;
  #     # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #     allowUnfreePredicate = _: true;
  #   };
  # };

  home = {
    username = "joaquin";
    homeDirectory = "/home/joaquin";
    sessionVariables = rec {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    sessionPath = [ config.home.sessionVariables."XDG_CONFIG_HOME" ];
  };

  # Add stuff for your user as you see fit:
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    withNodeJs = true;
  };
  xdg.configFile."nvim" = {
    source = ../nvim;
    recursive = true;
  };
  #xdg.configFile."nvim/lazy-lock.json" = {
  #  enable = false;
  #  source = config.lib.file.mkOutOfStoreSymlink ../nvim/lazy-lock.json;

  #};

  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Joaquín Triñanes";
    userEmail = "hi@joaquint.io";
    extraConfig = { init = { defaultBranch = "main"; }; };
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
    shellAliases = config.home.shellAliases;
  };
  programs.zoxide = {
    enable = true;
    options = [ "--cmd=j" ];
  };

  programs.ripgrep.enable = true;
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.enable_wayland = true

      return config
    '';
  };
  programs.starship = { enable = true; };

  programs.firefox = { enable = true; };

  gtk = {
    enable = true;

    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };

    # theme = {
    #   name = "palenight";
    #   package = pkgs.palenight-theme;
    # };
    #
    cursorTheme = {
      # name = "Numix-Cursor";
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors; # numix-cursor-theme;
    };

    # gtk3.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };
    #
    # gtk4.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };
  };

  home.sessionVariables.XCURSOR_THEME = "Bibata-Modern-Classic";
  home.shellAliases = {
    g = "git";
    ll = "ls -l";
    la = "ls -la";
  };

  services.gnome-keyring.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";

}
