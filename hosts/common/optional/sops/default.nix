{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops.age.keyFile = "/home/joaquin/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ../../../..;
  environment.systemPackages = with pkgs; [age];
}
