{inputs, ...}: {
  imports = [inputs.nh.nixosModules.default];
  nix.settings = {
    substituters = ["https://viperml.cachix.org"];
    trusted-public-keys = [
      "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="
    ];
  };

  nh.enable = true;
}
