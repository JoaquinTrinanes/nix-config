{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = with pkgs; [foo2zjs];
  };
}
