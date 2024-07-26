{
  lib,
  pkgs,
  config,
  ...
}:
{
  home = {
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isLinux then "/home/${config.home.username}" else "/Users/${config.home.username}"
    );
  };

  programs.ssh = {
    includes = [ "config.local" ];
  };

  programs.gpg.settings = {
    cert-digest-algo = "SHA512";
    charset = "utf-8";
    default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    default-recipient-self = true;
    fixed-list-mode = true;
    keyid-format = "long";
    keyserver = "hkps://keys.openpgp.org";
    list-options = "show-uid-validity";
    no-comments = true;
    no-emit-version = true;
    no-symkey-cache = true;
    personal-cipher-preferences = "AES256 AES192 AES";
    personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    personal-digest-preferences = "SHA512 SHA384 SHA256";
    require-cross-certification = true;
    s2k-cipher-algo = "AES256";
    s2k-digest-algo = "SHA512";
    tofu-default-policy = "unknown";
    trust-model = "tofu+pgp";
    use-agent = true;
    verify-options = "show-uid-validity";
    with-fingerprint = true;
    # Disable recipient key ID in messages
    throw-keyids = true;
  };

  # TODO: use sops for this
  # nix shell nixpkgs#pam_u2f --command pamu2fcfg
  # xdg.configFile."Yubico/u2f_keys".source = sops...
}
