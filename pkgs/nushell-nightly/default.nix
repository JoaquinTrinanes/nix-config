{
  stdenv,
  lib,
  rustPlatform,
  openssl,
  zlib,
  zstd,
  pkg-config,
  python3,
  xorg,
  nghttp2,
  libgit2,
  doCheck ? false,
  withDefaultFeatures ? true,
  additionalFeatures ? (p: p),
  testers,
  nushell,
  nix-update-script,
  darwin,
  craneLib,
  src,
}:
craneLib.buildPackage {
  inherit src doCheck;

  cargoExtraArgs = let
    features = additionalFeatures [];
    commaSeparatedFeatures = lib.concatStringsSep "," features;
  in
    lib.concatStringsSep " " ((lib.optionals (!withDefaultFeatures) ["--no-default-features"]) ++ lib.optionals (features != []) ["--features" commaSeparatedFeatures]);

  nativeBuildInputs =
    [pkg-config]
    ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [python3]
    ++ lib.optionals stdenv.isDarwin [rustPlatform.bindgenHook];

  buildInputs =
    [openssl zstd]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Libsystem
      darwin.apple_sdk.frameworks.Security
      zlib
    ]
    ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [xorg.libX11]
    ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [
      darwin.apple_sdk.frameworks.AppKit
      nghttp2
      libgit2
    ];

  passthru = {
    shellPath = "/bin/nu";
    tests.version = testers.testVersion {
      package = nushell;
    };
    updateScript = nix-update-script {};
  };
}
