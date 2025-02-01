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
    ./hetzner
    ./jellyfin
    ./nix-index
    ./printing
    ./samba
    ./ssh
    ./tailscale
    ./yubikey
  ];
}
