# Parse text as nix expression
export def "from nix" []: string -> any {
    nix eval --json -f - | from json
}

# Convert table data into a nix expression
export def "to nix" []: any -> string {
    to json --raw
    | str replace --all '$' "''$"
    | nix eval --expr $"builtins.fromJSON ''($in)''"
    | metadata set --content-type text/x-nix
}
