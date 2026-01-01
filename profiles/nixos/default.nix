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
    ./hardened
    ./printing
    ./ssh
    ./yubikey
  ];
}
