{ inputs, ... }: {
  imports = [ inputs.nixvim.nixosModules.nixvim ];
  programs.nixvim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    plugins = {
      bufferline.enable = true;
      alpha.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;
      lsp.enable = true;
      lualine.enable = true;

      telescope.enable = true;
      telescope.enabledExtensions = [ "fzf" ];
      neo-tree.enable = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      flavour = "frappe";
    };
  };
}
