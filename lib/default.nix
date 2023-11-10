{lib, ...}: {
  mkUser = {
    name,
    email,
    firstName ? name,
    lastName ? null,
    fullName ? (lib.concatStrings (lib.intersperse " " (lib.filter (x: x != null) [firstName lastName]))),
  }: {
    inherit name email firstName lastName fullName;
  };
}
