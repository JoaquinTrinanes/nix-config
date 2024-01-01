_: {
  services.openssh = {
    enable = true;
    settings = {
      Protocol = 2;
      PermitEmptyPasswords = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # PermitRootLogin = "yes";
    };
  };
}
