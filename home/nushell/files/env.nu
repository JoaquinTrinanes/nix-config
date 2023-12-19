# Nushell Environment Config File

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
export-env {
    let esep_list_converter = {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }

    $env.ENV_CONVERSIONS = {
        "PATH": $esep_list_converter
        "XDG_DATA_DIRS": $esep_list_converter
        "Path": $esep_list_converter
        "DIRS_LIST": $esep_list_converter
        "NU_LIB_DIRS": $esep_list_converter
        "NU_PLUGIN_DIRS": $esep_list_converter
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    # ($nu.config-path | path dirname | path join 'plugins')
]


export-env {
    load-env {
        PROMPT_INDICATOR_VI_NORMAL: ""
        PROMPT_INDICATOR_VI_INSERT: ""
    }
}
