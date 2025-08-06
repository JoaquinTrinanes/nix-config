{
  _class = "nixos";

  imports = [
    ./audio
    ./autofirma
    ./desktop
    ./development
    ./dnscrypt
    ./firefox
    ./fonts
    ./gaming
    ./hardware-acceleration
    ./jellyfin
    ./printing
    ./samba
    ./ssh
    ./tailscale
    ./yubikey
  ];
}
