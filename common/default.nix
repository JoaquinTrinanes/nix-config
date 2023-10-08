{ pkgs, inputs, ... }: {

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

  stylix = {
    targets.gnome.enable = false;

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
}
