{
  config,
  pkgs,
  lib,
  osConfig,
  user,
  inputs,
  self,
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
      ./dconf
      ./direnv
      ./wireplumber
      self.homeManagerModules.currentPath
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
      osConfig.users.users.${user.name}.home
      or (
        if pkgs.stdenv.isLinux
        then "/home/${config.home.username}"
        else "/Users/${config.home.username}"
      );
    sessionVariables =
      {
        NIXPKGS_ALLOW_UNFREE = 1;
      }
      // lib.optionalAttrs config.programs.bat.enable {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
    packages = with pkgs; let
      nixosRebuildWrapper = writeShellScriptBin "nx" ''
        nixos-rebuild --flake "${config.currentPath.source}" $@
      '';
    in [
      enpass
      nixosRebuildWrapper
      (writeShellScriptBin "nxs" ''
        ${nixosRebuildWrapper}/bin/nx switch
      '')
      (writeShellScriptBin "nr" ''
        nix run nixpkgs#$@
      '')
    ];
  };

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
    };
  };

  home.shellAliases =
    {
      l = "ls";
      ll = "ls -l";
      la = "ls -la";
      pn = "pnpm";
    }
    // lib.optionalAttrs config.programs.home-manager.enable {
      hm = ''home-manager --flake "${config.currentPath.source}"'';
      hms = "hm switch";
    }
    // lib.optionalAttrs config.programs.bat.enable {"cat" = "bat -p";};

  programs.less = {
    enable = true;
    keys = ''
      #env
      LESS = -i -R -F
    '';
  };

  programs.gpg = {
    enable = true;
    settings = {
      keyserver = "hkps://keys.openpgp.org";
      default-recipient-self = true;
      require-cross-certification = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = ["0405AAB779EE75EB11E9B4F148AC62E32DB2CD11"];
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
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 16;
  };

  home.stateVersion = "23.05";
}
