{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      foo2zjs
      cups-filters
      poppler_utils
    ];
    cups-pdf.enable = true;
    # extraConf = ''
    #   SetEnv PATH /var/lib/cups/path/lib/cups/filter:/var/lib/cups/path/bin
    # '';
    # logLevel = "debug";
  };
  # environment.systemPackages = with pkgs; [ghostscript gutenprint cups-filters];
}
