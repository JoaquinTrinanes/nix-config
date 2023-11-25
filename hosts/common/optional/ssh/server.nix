_: {
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII95dwUzUX98GxBzc13L/u/k+0rnZys6xDhNeEdkrsbq joaquin@razer-blade-14"
    ];
    #settings.PermitRootLogin = "yes";
  };
}
