{
  config,
  pkgs,
  lib,
  user,
  inputs,
  ...
}: {
  _module.args.myLib = import ../../lib {inherit lib config;};
  imports = [
    ./git
    ./neovim
    ./nushell
    ./dconf
    ./direnv
    ./wireplumber
    ./wezterm
    ./firefox
    inputs.nix-colors.homeManagerModules.default
  ];

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  home = {
    username = user.name;
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${config.home.username}"
      else "/Users/${config.home.username}";
    sessionVariables = lib.mkMerge [
      {
        NIXPKGS_ALLOW_UNFREE = 1;
      }
      (lib.mkIf config.programs.neovim.enable {
        MANPAGER = "nvim +Man!";
        # MANROFFOPT = "-c";
      })
      # (lib.mkIf config.programs.bat.enable {
      #   PAGER = "";
      #   MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      #   # MANROFFOPT = "-c";
      # })
    ];

    packages = with pkgs; let
      # this has to be a wrapper and not an alias to be able to call if with sudo
      nixosRebuildWrapper = writeShellScriptBin "nx" ''
        ${lib.getExe pkgs.nixos-rebuild} "$@"
      '';
    in [
      enpass
      nixosRebuildWrapper
      (writeShellScriptBin "nxs" ''
        ${lib.getExe nixosRebuildWrapper} switch "$@"
      '')
      (writeShellScriptBin "nr" ''
        nix run nixpkgs#"$@"
      '')
    ];
  };

  programs.home-manager.enable = true;

  programs.bash.enable = true;

  programs.rtx = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    options = ["--cmd=j"];
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--auto-hybrid-regex"
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      continuation_prompt = "::: ";
      character = {
        success_symbol = "[➜](bold fg:green)";
        error_symbol = "[➜](bold fg:blue)";
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

      # docker compose
      dc = "docker compose";
      dcup = "docker compose up";
      dcupd = "docker compose up -d";
      dcdn = "docker compose down";
      dcrm = "docker compose rm";
    }
    // lib.optionalAttrs (config.programs.home-manager.enable && !config.submoduleSupport.enable) {
      hm = "home-manager";
      hms = "home-manager switch";
    }
    // lib.optionalAttrs config.programs.bat.enable {"cat" = "bat -p";};

  programs.less = {
    enable = true;
    keys = ''
      #env
      LESS = --ignore-case --RAW-CONTROL-CHARS --quit-if-one-screen
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
