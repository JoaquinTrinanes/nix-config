# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    inputs.home-manager.nixosModules.home-manager
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      inputs.neovim-nightly-overlay.overlay

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      joaquin = import ../home-manager/home.nix;
    };
    useGlobalPkgs = true;
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      substituters =
        [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # FIXME: Add the rest of your current configuration

  # TODO: Set your hostname
  networking.hostName = "your-hostname";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    joaquin = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" ];
    };
  };

  networking.networkmanager.enable = true;

  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; }) ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.libinput.touchpad = {
    tapping = true;
    scrollMethod = "twofinger";
    naturalScrolling = true;
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    dconf.enable = true;
    steam.enable = true;
    npm.enable = true;
  };

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    polarity = "dark";
    image = pkgs.fetchurl {
      url =
        "https://cdn.discordapp.com/attachments/923640537356070972/1005882583348936774/5a266e448add93deab367d87173e9f25-683788614.png";
      hash = "sha256-bSHxrJI60pZi0ISpdG+4k8Wqp4bEH/VReWvACeO3E2Q=";
    };
    fonts = {
      monospace = {
        package =
          (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; });
        name = "FiraCode Nerd Font";
      };
    };
  };

  environment.systemPackages = (with pkgs;
    [
      alejandra
      firefox
      nil
      git
      wget
      nil
      nixfmt
      # clang
      # libclang
      gcc
      libgcc
      wl-clipboard
      libcxx
      stylua
      ripgrep
      fzf
      gnumake
      lua-language-server
      lshw
    ] ++ (with gnome; [ gnome-tweaks adwaita-icon-theme ])
    ++ (with gnomeExtensions; [ appindicator dash-to-panel espresso ]));

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   # Forbid root login through SSH.
  #   permitRootLogin = "no";
  #   # Use keys only. Remove if you want to SSH using password (not recommended)
  #   passwordAuthentication = false;
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
