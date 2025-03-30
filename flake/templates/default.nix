{
  flake.templates = {
    node_prisma = {
      path = ./node-prisma;
      description = "Node devenv flake with prisma and corepack support";
    };
    rust = {
      path = ./rust;
      description = "Basic Rust setup";
    };
    flake-parts = {
      path = ./flake-parts;
      description = "flake-parts devShell";
    };
  };
}
