{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  zlib,
  zstd,
  pkg-config,
  python3,
  xorg,
  darwin,
  nghttp2,
  libgit2,
  doCheck ? true,
  withDefaultFeatures ? true,
  additionalFeatures ? (p: p),
  testers,
  nushell,
  nix-update-script,
}: let
  src = fetchFromGitHub {
    owner = "nushell";
    repo = "nushell";
    rev = "54398f9546ab3b7715e9f0fa6649e3510d44e626";
    hash = "sha256-rL5DpRX7FBzvIklji/ggEf0/qR3aH1BAE+XNKma4urg=";
  };
  manifest = builtins.fromTOML (builtins.readFile "${src}/Cargo.toml");
  inherit (manifest.package) version;
in
  rustPlatform.buildRustPackage {
    pname = "nushell";
    inherit src version;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "lsp-server-0.7.4" = "sha256-TEYr3dOEXBt714uKx1uEsI4pB1TkUjXazfN1Z8icyEU=";
      };
    };

    nativeBuildInputs =
      [pkg-config]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [python3]
      ++ lib.optionals stdenv.isDarwin [rustPlatform.bindgenHook];

    buildInputs =
      [openssl zstd]
      ++ lib.optionals stdenv.isDarwin [
        zlib
        darwin.apple_sdk.frameworks.Libsystem
        darwin.apple_sdk.frameworks.Security
      ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [xorg.libX11]
      ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [darwin.apple_sdk.AppKit nghttp2 libgit2];

    buildNoDefaultFeatures = !withDefaultFeatures;
    buildFeatures = additionalFeatures [];

    inherit doCheck;

    checkPhase = ''
      runHook preCheck
      echo "Running cargo test"
      HOME=$(mktemp -d) cargo test
      runHook postCheck
    '';

    passthru = {
      shellPath = "/bin/nu";
      tests.version = testers.testVersion {
        package = nushell;
      };
      updateScript = nix-update-script {};
    };

    meta = with lib; {
      description = "A modern shell written in Rust";
      homepage = "https://www.nushell.sh/";
      license = licenses.mit;
      maintainers = [];
      mainProgram = "nu";
    };
  }
