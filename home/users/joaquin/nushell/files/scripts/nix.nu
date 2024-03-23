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

