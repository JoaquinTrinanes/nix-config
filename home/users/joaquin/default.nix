{
  config,
  pkgs,
  lib,
  inputs,
  myLib,
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

  impurePath = lib.mkDefault {
    enable = true;
    flakePath = "${config.home.homeDirectory}/Documents/nix-config";
    repoUrl = "https://github.com/JoaquinTrinanes/nix-config.git";
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
    };
    package = myLib.mkWrapper {
      basePackage = pkgs.jujutsu;
      env."JJ_CONFIG" = {
        value = config.xdg.configFile."jj/config.toml".source;
        force = false;
      };
    };
  };
  xdg.configFile."jj/config.toml".enable = false;

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
      in
      [ nr ] ++ builtins.attrValues { inherit (pkgs) enpass; };
  };

  programs.home-manager.enable = true;

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

  programs.zoxide = {
    enable = true;
    options = [ "--cmd=j" ];
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
      };
    };
  };

  xdg.configFile."pnpm/rc".source =
    let
      keyValue = pkgs.formats.keyValue { };
    in
    keyValue.generate "rc" { update-notifier = false; };

  home.shellAliases =
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

      nx = "nixos-rebuild --use-remote-sudo";
      nxs = "nx switch";
    }
    // lib.optionalAttrs (config.programs.home-manager.enable && !config.submoduleSupport.enable) {
      hm = "home-manager";
      hms = "home-manager switch";
    }
    // lib.optionalAttrs config.programs.bat.enable {
      b = "bat";
      "cat" = "bat -p";
    };

  programs.gpg = {
    enable = true;
    settings = {
      keyserver = "hkps://keys.openpgp.org";
      default-recipient-self = true;
    };
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
    # TODO: move to module
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

  home.pointerCursor = rec {
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = name;
    };
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 16;
  };

  gtk.iconTheme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };

  # xdg.configFile."Proton/VPN/settings.json".text = builtins.toJSON {
  #   dns_custom_ips = [];
  #   features = {
  #     moderate_nat = false;
  #     netshield = 0; # 0 = disabled, 1 = block malware, 2 = block ads, trackers and malware
  #     port_forwarding = false;
  #     vpn_accelerator = true;
  #   };
  #   killswitch = 0; # 0, 1
  #   protocol = "openvpn-udp"; # openvpn-udp, openvpn-tcp
  # };
  # xdg.configFile."Proton/VPN/app-config.json".text = builtins.toJSON {
  #   connect_at_app_startup = null;
  #   tray_pinned_servers = ["ES" "US"];
  # };
}
