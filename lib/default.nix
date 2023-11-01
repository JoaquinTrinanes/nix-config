{lib, ...}: {
  mkHomeManagerUser = {
    name,
    email,
    firstName ? name,
    lastName ? null,
    fullName ? (lib.concatStrings (lib.intersperse " " (lib.filter (x: x != null) [_user.firstName _user.lastName]))),
  } @ _user: config: ({pkgs, ...}: let
    user = {
      inherit name email firstName lastName fullName;
    };
  in {
    home-manager = {
      extraSpecialArgs = {inherit user;};
      users."${user.name}" = config;
    };
    users.users."${user.name}".packages = with pkgs; [home-manager];
  });
}
