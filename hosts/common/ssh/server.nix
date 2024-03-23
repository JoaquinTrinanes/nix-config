{
  services.openssh = {
    enable = true;
    settings = {
      PermitEmptyPasswords = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # PermitRootLogin = "yes";
    };
  };
}
