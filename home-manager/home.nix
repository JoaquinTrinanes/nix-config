{
  config,
  pkgs,
  lib,
  user,
  inputs,
  self,
  ...
}: {
  _module.args.myLib = import ./lib {inherit lib config;};
  imports = [
    ./git
    ./neovim
    ./nushell
    ./dconf
    ./direnv
    ./wireplumber
    ./wezterm
    ./firefox
    self.homeManagerModules.currentPath
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  home = {
    username = user.name;
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${config.home.username}"
      else "/Users/${config.home.username}";
    sessionVariables =
      {
        NIXPKGS_ALLOW_UNFREE = 1;
      }
      // lib.optionalAttrs config.programs.bat.enable {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
    packages = with pkgs; let
      # this has to be a wrapper and not an alias to be able to call if with sudo
      nixosRebuildWrapper = writeShellScriptBin "nx" ''
        nixos-rebuild "$@"
      '';
    in [
      enpass
      nixosRebuildWrapper
      (writeShellScriptBin "nxs" ''
        ${lib.getExe nixosRebuildWrapper} switch
      '')
      (writeShellScriptBin "nr" ''
        nix run nixpkgs#"$@"
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
      hm = "home-manager";
      hms = "home-manager switch";
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
    pinentryFlavor = "gnome3";
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

  home.pointerCursor = rec {
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = name;
    };
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 16;
  };
}
