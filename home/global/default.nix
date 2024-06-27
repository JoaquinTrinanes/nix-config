{
  lib,
  user,
  pkgs,
  ...
}:
{
  imports = [ ../lib ];
  home = {
    username = lib.mkDefault user.name;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isLinux then "/home/${user.name}" else "/Users/${user.name}"
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
  xdg.configFile."Yubico/u2f_keys" = lib.mkIf (user.u2f != [ ]) {
    text =
      let
        mkKey =
          {
            keyHandle,
            userKey,
            coseType,
            options,
          }:
          lib.concatStringsSep "," [
            keyHandle
            userKey
            coseType
            options
          ];
      in
      lib.concatLines user.u2f;
  };
}
