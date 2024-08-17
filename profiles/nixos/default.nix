{
  _class = "nixos";
  imports = [
    ./audio
    ./autofirma
    ./desktop
    ./development
    ./firefox
    ./fonts
    ./gaming
    ./garbage-collect
    ./hardware-acceleration
    ./nix-index
    ./printing
    ./tailscale
    ./yubikey
  ];
}
