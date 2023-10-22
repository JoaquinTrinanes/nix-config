{outputs, ...}: {
  nixpkgs = {
    overlays = with outputs.overlays; [
      additions
      modifications
      unstable-packages
      neovim-nightly
    ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
}
