{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = "https://devenv.cachix.org";
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  };

  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];

      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, ... }:
        {
          devenv.shells.default = {
            languages.javascript = {
              enable = true;
              package = pkgs.nodejs_20;
              corepack.enable = true;
            };
            env =
              let
                inherit (pkgs) prisma-engines;
              in
              {
                PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
                PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
                PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
                PRISMA_INTROSPECTION_ENGINE_BINARY = "${prisma-engines}/bin/introspection-engine";
                PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
              };
          };
        };
    };
}
