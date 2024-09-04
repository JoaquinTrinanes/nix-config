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
    charset = "utf-8";
    list-options = "show-uid-validity";
    require-cross-certification = true;
    keyid-format = "long";
    no-symkey-cache = true;
    no-emit-version = true;
    no-comments = true;
    default-recipient-self = true;
    tofu-default-policy = "unknown";
    trust-model = "tofu+pgp";
    use-agent = true;
    verify-options = "show-uid-validity";
    with-fingerprint = true;
    # Disable recipient key ID in messages
    throw-keyids = true;

    # # GPG defaults are decent now
    # cert-digest-algo = "SHA512";
    # default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    # personal-cipher-preferences = "AES256 AES192 AES";
    # personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    # personal-digest-preferences = "SHA512 SHA384 SHA256";
    # s2k-cipher-algo = "AES256";
    # s2k-digest-algo = "SHA512";
  };

  home.file."${config.programs.gpg.homedir}/dirmngr.conf".text =
    lib.generators.toKeyValue
      {
        mkKeyValue =
          key: value: if lib.isString value then "${key} ${value}" else lib.optionalString value key;
        listsAsDuplicateKeys = true;
      }
      {
        keyserver = [
          "hkps://keys.openpgp.org"
          "hkp://zkaan2xfbuxia2wpf7ofnkbz6r5zdbbvxbunvp5g2iebopbfc4iqmbad.onion"
        ];
      };

  # TODO: use sops for this
  # nix shell nixpkgs#pam_u2f --command pamu2fcfg
  # xdg.configFile."Yubico/u2f_keys".source = sops...
}
