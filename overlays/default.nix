{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system};

  modifications = final: prev: {};
}
