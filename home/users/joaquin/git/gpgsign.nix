_: {
  programs.git.extraConfig = {
    commit = {gpgsign = true;};
    tag = {gpgsign = true;};
  };
}
