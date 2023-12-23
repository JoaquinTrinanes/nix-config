const SCRIPTS_DIR = ($nu.default-config-dir | path join scripts)

export use ($SCRIPTS_DIR | path join nix.nu) *
