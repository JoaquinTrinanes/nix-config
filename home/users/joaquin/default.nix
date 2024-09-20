{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./git
    ./neovim
    ./nushell
    ./gnome
    ./direnv
    ./wireplumber
    ./wezterm
    ./kitty
    ./carapace
    inputs.nix-colors.homeManagerModules.default
  ];

  accounts.email.accounts = {
    primary = {
      primary = true;
      address = "hi@joaquint.io";
      realName = "Joaquín Triñanes";
    };
    vh = {
      address = "joaquin@veganhacktivists.org";
    };
  };

  impurePath = lib.mkDefault {
    enable = true;
    inherit (inputs) self;
    flakePath = "${config.home.homeDirectory}/Documents/nix-config";
    remote = {
      name = "origin";
      url = "git@github.com:JoaquinTrinanes/nix-config.git";
    };
  };

  xdg = {
    enable = true;
    mimeApps.enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        inherit (config.programs.git.iniContent.user) name email;
      };
    };
  };

  programs.password-store.enable = true;

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  programs.less = {
    enable = true;
    keys = ''
      #env
      LESS = --ignore-case --RAW-CONTROL-CHARS --quit-if-one-screen
    '';
  };

  home = {
    sessionVariables = lib.mkIf config.programs.neovim.enable { MANPAGER = "nvim +Man!"; };

    packages =
      let
        nr = pkgs.writeShellScriptBin "nr" ''
          nix run nixpkgs#"$@"
        '';
        ripgrep = lib.my.mkWrapper {
          basePackage = pkgs.ripgrep;
          env."RIPGREP_CONFIG_PATH" = {
            value = pkgs.writeText "ripgreprc" (lib.concatLines config.programs.ripgrep.arguments);
            force = false;
          };
        };
      in
      builtins.attrValues {
        inherit nr ripgrep;
        inherit (pkgs) enpass;
      };
  };

  programs.home-manager.enable = lib.mkDefault (!config.submoduleSupport.enable);

  programs.bash.enable = true;

  programs.bash.initExtra = lib.mkIf (config.home.shellAliases != { }) (
    lib.mkAfter (
      lib.concatLines (
        [
          ''
            source ${lib.getExe pkgs.complete-alias}
          ''
        ]
        ++ map (alias: "complete -F _complete_alias ${lib.escapeShellArg alias}") (
          builtins.attrNames config.home.shellAliases
        )
      )
    )
  );

  programs.mise = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  programs.git.ignores = lib.mkIf config.programs.mise.enable [
    ".mise.local.toml"
    ".mise.*.local.toml"
  ];

  programs.zoxide = {
    enable = true;
    options = [ "--cmd=j" ];
  };

  programs.ripgrep = {
    # managed through the wrapper
    enable = false;
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
      };
    };
  };

  xdg.configFile."pnpm/rc".source =
    let
      keyValue = pkgs.formats.keyValue { };
    in
    keyValue.generate "rc" { update-notifier = false; };

  home.shellAliases = lib.mkMerge [
    {
      l = "ls";
      ll = "ls -l";
      la = "ls -la";
      pn = "pnpm";

      dc = "docker compose";
      dcup = "docker compose up";
      dcupd = "docker compose up -d";
      dcdn = "docker compose down";
      dcrm = "docker compose rm";

      nx = "nixos-rebuild --use-remote-sudo --accept-flake-config";
      nxs = "nx switch";
    }
    (lib.mkIf (config.programs.home-manager.enable && !config.submoduleSupport.enable) {
      hm = "home-manager";
      hms = "home-manager switch";
    })
    (lib.mkIf config.programs.bat.enable {
      b = "bat";
      "cat" = "bat -p";
    })
  ];

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  # Disable gnome-keyring ssh-agent
  xdg.configFile."autostart/gnome-keyring-ssh.desktop" = {
    enable = config.services.gpg-agent.enableSshSupport;
    text = ''
      [Desktop Entry]
      Name=Disable Gnome SSH Key Agent
      Type=Application
      Hidden=true
    '';
  };

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      # keymap_mode = "vim-normal";
      # https://docs.rs/regex/latest/regex/#syntax
      history_filter = [ "^\\s+" ];
      # number of context lines to show when scrolling by pages
      scroll_context_lines = 3;
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      SetEnv TERM="xterm-256color"
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.pointerCursor = {
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 16;
  };

  gtk.iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };

  home.stateVersion = "24.11";
}
