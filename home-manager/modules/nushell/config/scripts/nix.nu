# export def --wrapped "nix search" [pkg?: string ...args] {
#     ^nix search --json --offline $args nixpkgs $pkg | from json
# }
#
# export def --wrapped "nix run" [pkg?: string ...args] {
#     ^nix run (if $pkg != null { $"nixpkgs#($pkg)" } else { [] }) $args
# }
#
# export def --wrapped "nix profile list" [...args] {
#     ^nix profile list --json $args | from json
# }

export def "from nix" []: string -> any {
  nix eval --json --expr $in | from json
}

export def "to nix" []: any -> string {
  to json
  | nix eval --expr $"builtins.fromJSON ''($in)''"
  | nix run `nixpkgs#alejandra` -- -q
}
