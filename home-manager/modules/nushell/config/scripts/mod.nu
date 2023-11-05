const SCRIPTS_DIR = ($nu.default-config-dir | path join scripts)

# overlay use ($SCRIPTS_DIR | path join aliases)
# overlay use ($SCRIPTS_DIR | path join completions)
export use ($SCRIPTS_DIR | path join nix.nu) *
