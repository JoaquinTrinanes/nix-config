{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./carapace
    ./direnv
    ./git
    ./gnome
    ./jujutsu
    ./neovim
    ./nushell
    ./terminal
    ./sound

    inputs.nix-index-database.homeModules.nix-index
  ];

  home.shell = {
    enableShellIntegration = false;
  };

  accounts.email.accounts = {
    primary = {
      primary = true;
      address = "hi@joaquint.io";
      realName = "Joaquín Triñanes";
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

  programs.password-store.enable = true;

  colors = {
    name = "Catppuccin Frappe";
    slug = "catppuccin-frappe";
    palette = {
      base00 = "#303446"; # base
      base01 = "#292c3c"; # mantle
      base02 = "#414559"; # surface0
      base03 = "#51576d"; # surface1
      base04 = "#626880"; # surface2
      base05 = "#c6d0f5"; # text
      base06 = "#f2d5cf"; # rosewater
      base07 = "#babbf1"; # lavender
      base08 = "#e78284"; # red
      base09 = "#ef9f76"; # peach
      base0A = "#e5c890"; # yellow
      base0B = "#a6d189"; # green
      base0C = "#81c8be"; # teal
      base0D = "#8caaee"; # blue
      base0E = "#ca9ee6"; # mauve
      base0F = "#eebebe"; # flamingo
      base10 = "#292c3c"; # mantle - darker background
      base11 = "#232634"; # crust - darkest background
      base12 = "#ea999c"; # maroon - bright red
      base13 = "#f2d5cf"; # rosewater - bright yellow
      base14 = "#a6d189"; # green - bright green
      base15 = "#99d1db"; # sky - bright cyan
      base16 = "#85c1dc"; # sapphire - bright blue
      base17 = "#f4b8e4"; # pink - bright purple
    };
  };

  programs.less = {
    enable = true;
    config = ''
      #env
      LESS = --ignore-case --RAW-CONTROL-CHARS --quit-if-one-screen
    '';
  };

  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    globalConfig = {
      settings = {
        all_compile = false;
        experimental = true;
        not_found_auto_install = false;
        idiomatic_version_file_enable_tools = [
          "go"
          "node"
          "rust"
        ];
      };
    };
  };

  programs.git.ignores = lib.mkIf config.programs.mise.enable [
    "mise.local.*"
    "mise.*.local.*"
    ".mise.local.*"
    ".mise.*.local.*"
  ];

  home = {
    sessionVariables = lib.mkMerge [
      (lib.mkIf config.programs.neovim.enable { MANPAGER = "nvim +Man!"; })
      {
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      }
    ];

    packages = builtins.attrValues {
      nr = pkgs.writeShellScriptBin "nr" ''
        nix run nixpkgs#"$@"
      '';
      ripgrep = pkgs.my.mkWrapper {
        basePackage = pkgs.ripgrep;
        env."RIPGREP_CONFIG_PATH" = {
          value = pkgs.writeText "ripgreprc" (lib.concatLines config.programs.ripgrep.arguments);
          force = false;
        };
      };
      inherit (pkgs)
        ast-grep
        enpass
        glow
        ffmpeg
        imagemagick
        mergiraf
        ;
      topiary =
        let
          topiary-nushell = builtins.fetchTree {
            type = "github";
            owner = "blindFS";
            repo = "topiary-nushell";
            rev = "7f836bc14e0a435240c190b89ea02846ac883632";
          };
          tree-sitter-nu = pkgs.tree-sitter.buildGrammar {
            language = "nu";
            version = "0.0.0+rev=d5c71a10";
            src = builtins.fetchTree {
              type = "github";
              owner = "nushell";
              repo = "tree-sitter-nu";
              rev = "d5c71a10b4d1b02e38967b05f8de70e847448dd1";
            };
            meta.homepage = "https://github.com/nushell/tree-sitter-nu";
          };
        in
        pkgs.my.mkWrapper {
          basePackage = pkgs.topiary;
          prependFlags = [ "--merge-configuration" ];
          env = {
            TOPIARY_CONFIG_FILE.value =
              pkgs.writeText "languages.ncl"
                # nickel
                ''
                  {
                    languages = {
                      nu = {
                        indent = "    ", # 4 spaces
                        extensions = ["nu"],
                        grammar.source.path = "${tree-sitter-nu}/parser"
                      },
                    },
                  }
                '';
            TOPIARY_LANGUAGE_DIR.value = "${topiary-nushell}/languages";
          };
        };
    };
  };

  programs.bash.enable = true;

  programs.bash.initExtra = lib.mkMerge [
    (lib.mkIf (config.home.shellAliases != { }) (
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
    ))
    (lib.mkAfter ''
      if [ -f "$HOME/.bashrc.local" ]; then
        source "$HOME/.bashrc.local"
      fi
    '')
  ];

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    options = [ "--cmd=z" ];
  };

  programs.ripgrep = {
    # managed through the wrapper
    enable = false;
    arguments = [
      "--smart-case"
      "--engine=auto"
    ];
  };

  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;

    settings = {
      add_newline = true;
      # continuation_prompt = "::: ";
      continuation_prompt = "    ";
      character = {
        success_symbol = "[➜](bold fg:green)";
        error_symbol = "[➜](bold fg:blue)";
        # success_symbol = "[;](bold fg:green)";
        # error_symbol = "[;](bold fg:blue)";
      };
      aws.disabled = true;
      directory.truncation_length = 5;

      git_branch = {
        only_attached = true;
      };
      git_status = {
        disabled = true;
      };
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

      nx = "nixos-rebuild --sudo --accept-flake-config --option allow-import-from-derivation false";

      nxs = "nx switch";
      # prevent leaking information from secure files
      svim = "${lib.getExe config.programs.neovim.package} -n --cmd 'au BufRead * setlocal nobackup nomodeline noshelltemp noswapfile noundofile nowritebackup shadafile=NONE'";
    }
    (lib.mkIf config.programs.home-manager.enable {
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
    enableBashIntegration = true;
    enableNushellIntegration = true;
    pinentry.package = pkgs.pinentry-tty;

    # timeout since last activity
    defaultCacheTtl = 15 * 60; # 15 minutes
    # timeout since password last entered
    maxCacheTtl = 15 * 60;
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

  xdg.mimeApps.defaultApplications =
    let
      defaultWebBrowser = lib.mkAfter [
        pkgs.firefox.desktopItem.name
      ];
      defaultEditor = lib.mkAfter [ "nvim.desktop" ];
    in
    {
      "x-scheme-handler/http" = defaultWebBrowser;
      "x-scheme-handler/https" = defaultWebBrowser;
      "x-scheme-handler/chrome" = defaultWebBrowser;
      "text/html" = defaultWebBrowser;
      "application/pdf" = defaultWebBrowser;
      "application/x-extension-htm" = defaultWebBrowser;
      "application/x-extension-html" = defaultWebBrowser;
      "application/x-extension-shtml" = defaultWebBrowser;
      "application/xhtml+xml" = defaultWebBrowser;
      "application/x-extension-xhtml" = defaultWebBrowser;
      "application/x-extension-xht" = defaultWebBrowser;

      # any other editor that defines these mimetypes in its desktop file could take precedence, so they are explicitly declared
      "text/plain" = defaultEditor;
      "text/english" = defaultEditor;
      "text/x-makefile" = defaultEditor;
      "text/x-c++hdr" = defaultEditor;
      "text/x-c++src" = defaultEditor;
      "text/x-chdr" = defaultEditor;
      "text/x-csrc" = defaultEditor;
      "text/x-java" = defaultEditor;
      "text/x-moc" = defaultEditor;
      "text/x-pascal" = defaultEditor;
      "text/x-tcl" = defaultEditor;
      "text/x-tex" = defaultEditor;
      "application/x-shellscript" = defaultEditor;
      "text/x-c" = defaultEditor;
      "text/x-c++" = defaultEditor;
    };

  programs.atuin = {
    enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;

    flags = [ "--disable-up-arrow" ];
    daemon.enable = true;
    settings = {
      auto_sync = false;
      sync_address = "https://atuin.joaquint.io";
      sync.records = true;
      dotfiles.enable = true;
      history_filter = [ "^\\s+" ];
      scroll_context_lines = 3;
      keymap_mode = "vim-insert";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  programs.ssh = {
    enable = true;
    # Fix pinentry appearing in wrong terminal
    # https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY
    # https://unix.stackexchange.com/questions/280879/how-to-get-pinentry-curses-to-start-on-the-correct-tty/499133#499133
    matchBlocks."*".match = ''host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"'';
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };

  home.stateVersion = "25.05";
}
