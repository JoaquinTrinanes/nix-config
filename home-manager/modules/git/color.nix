_: {
  programs.git.extraConfig.color = {
    ui = true;
    diff = {
      meta = "yellow bold";
      frag = "magenta bold";
      old = "red bold";
      new = "green bold";
    };
    status = {
      added = "yellow";
      changed = "magenta";
      untracked = "green";
    };
    branch = {
      current = "yellow reverse";
      local = "yellow";
      remote = "green";
    };
    branch = {};
  };
}
