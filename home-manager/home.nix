{
  config,
  pkgs,
  lib,
  osConfig,
  user,
  inputs,
  outputs,
  ...
}: let
  # safe access osConfig, as it's not set when using standalone home-manager
  hasGui = osConfig.services.xserver.enable or true;
  hasGnome = osConfig.services.xserver.desktopManager.gnome.enable or true;
in {
  imports =
    [
      ./git
      ./neovim
      ./nushell
      ./direnv
      outputs.homeManagerModules.currentPath
      inputs.nix-colors.homeManagerModules.default
    ]
    ++ (lib.optionals hasGui [
      ./wezterm
      ./firefox
    ]);

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  home = {
    username = user.name;
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${config.home.username}"
      else "/Users/${config.home.username}";
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = 1;

      # fixes GPG agent not being used as SSH agent due to gnome-keyring
      # GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
      # SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
      SSH_AUTH_SOCK = "";

      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    sessionPath = [config.home.sessionVariables."XDG_BIN_HOME"];
    packages = with pkgs; [
      enpass
    ];
  };
  xdg.systemDirs.data = [
    # show desktop entries
    "$HOME/.nix-profile/share"
  ];
  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = "";
  };

  # Add stuff for your user as you see fit:

  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.bash.enable = true;

  programs.rtx.enable = true;

  programs.zoxide = {
    enable = true;
    options = ["--cmd=j"];
  };

  programs.ripgrep.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      continuation_prompt = "[:::](bright-black) ";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold blue)";
      };
      aws.disabled = true;
      directory.truncation_length = 5;
      php.format = "via [$symbol]($style)";

      python.format = "via [\${symbol}\${pyenv_prefix}(\${version})]($style) ";
      status = {
        disabled = false;
        symbol = "✘";
      };
      shell = {
        disabled = false;
        nu_indicator = "";
        format = "([$indicator](style) )";
      };
      nix_shell = {
        impure_msg = "";
        # format = "via [$symbol($state)($name)]($style) ";
      };
    };
  };

  home.shellAliases = lib.mkMerge [
    {
      "l" = "ls";
      "ll" = "ls -l";
      "la" = "ls -la";
      "pn" = "pnpm";
      "hm" = "home-manager";
    }
    (lib.mkIf
      config.programs.bat.enable
      {"cat" = "bat -p";})
  ];

  programs.gpg.enable = true;
  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [
    "pkcs11"
    "secrets"
    # "ssh"
  ];
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = ["3F9EFD3BDEA64344C9F1FF2B6230454F4BE7405F"];
    pinentryFlavor =
      if hasGnome
      then "gnome3"
      else "gtk2";
  };
  # Disable gnome-keyring ssh-agent
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.pointerCursor = lib.mkIf hasGui rec {
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = name;
    };
    name = "DMZ-Black";
    package = pkgs.vanilla-dmz;
  };

  dconf.settings = with lib.hm.gvariant;
    lib.mkIf hasGui {
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
        natural-scroll = false;
      };
      "org/gnome/shell" = {
        favorite-apps = ["org.gnome.Nautilus.desktop" "firefox.desktop" "discord.desktop" "org.wezfurlong.wezterm.desktop"];
        enabled-extensions = with pkgs.gnomeExtensions;
          builtins.map (extension: extension.extensionUuid) [
            dash-to-panel
            espresso
            appindicator
            night-theme-switcher
          ];
      };
      "org/gnome/desktop/interface" = {
        text-scaling-factor = 1.25;
        show-battery-percentage = true;
        enable-hot-corners = false;
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/shell/extensions/espresso" = {
        show-notifications = false;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "wezterm";
        name = "Launch terminal";
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-windows = ["<Alt>Tab"];
        switch-windows-backward = ["<Shift><Alt>Tab"];
        switch-applications = ["<Super>Tab"];
        switch-applications-backward = ["<Shift><Super>Tab"];
      };
      "org/gnome/desktop/input-sources" = {
        sources = [(mkTuple ["xkb" "us"]) (mkTuple ["xkb" "es"])];
      };
      # "org/gnome/desktop/datetime" = {
      #   automatic-timezone = true;
      # };
      # "org/gnome/system/location" = {
      #   enabled = true;
      # };
    };

  home.stateVersion = "23.05";
}
