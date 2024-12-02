# Nushell Environment Config File

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
export-env {
    def converter_by_separator [sep: string] {
        {
            from_string: {|s| $s | split row $sep }
            to_string: {|v| $v | str join $sep }
        }
    }

    let esep_list_converter = converter_by_separator (char esep)
    let space_list_converter = converter_by_separator (char space)

    $env.ENV_CONVERSIONS = {
        "DIRS_LIST": $esep_list_converter
        "GIO_EXTRA_MODULES": $esep_list_converter
        "GTK_PATH": $esep_list_converter
        "INFOPATH": $esep_list_converter
        "LIBEXEC_PATH": $esep_list_converter
        "LS_COLORS": $esep_list_converter
        "NU_LIB_DIRS": $esep_list_converter
        "NU_PLUGIN_DIRS": $esep_list_converter
        "PATH": $esep_list_converter
        "Path": $esep_list_converter
        "QTWEBKIT_PLUGIN_PATH": $esep_list_converter
        "SESSION_MANAGER": $esep_list_converter
        "TERMINFO_DIRS": $esep_list_converter
        "XCURSOR_PATH": $esep_list_converter
        "XDG_CONFIG_DIRS": $esep_list_converter
        "XDG_DATA_DIRS": $esep_list_converter

        "NIX_PROFILES": $space_list_converter
    }
}


if (is-terminal --stdin) {
    $env.GPG_TTY = (tty)
}

# $env.NU_LIB_DIRS = [
#     ($nu.default-config-dir | path join 'scripts')
# ]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
# $env.NU_PLUGIN_DIRS = [
#     # ($nu.config-path | path dirname | path join 'plugins')
# ]

export-env {
    load-env {
        PROMPT_INDICATOR_VI_NORMAL: ""
        PROMPT_INDICATOR_VI_INSERT: ""
    }
}
