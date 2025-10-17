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
        "PATH": $esep_list_converter
        "QTWEBKIT_PLUGIN_PATH": $esep_list_converter
        "SESSION_MANAGER": $esep_list_converter
        "TERMINFO_DIRS": $esep_list_converter
        "XCURSOR_PATH": $esep_list_converter
        "XDG_CONFIG_DIRS": $esep_list_converter
        "XDG_DATA_DIRS": $esep_list_converter

        "NIX_PROFILES": $space_list_converter
    }
}

export-env {
    def relative_luminance [color] {
        def relative_luminance_helper [x: float] {
            if $x <= 0.03928 {
                $x / 12.92
            } else {
                ((($x + 0.055) / 1.055) ** 2.4)
            }
        }

        let rgb = $color
        | str trim -c '#' --left
        | split chars
        | window 2 --stride 2
        | each { str join }
        | into int --radix 16
        | each {|v| relative_luminance_helper ($v / 255) }

        let r = $rgb.0
        let b = $rgb.1
        let g = $rgb.2

        (0.2126 * $r) + (0.7152 * $g) + (0.0722 * $b)
    }

    def contrast [color1 color2] {
        let l1 = relative_luminance $color1
        let l2 = relative_luminance $color2

        let lighter = [$l1 $l2] | math max
        let darker = [$l1 $l2] | math min

        ($lighter + 0.05) / ($darker + 0.05)
    }

    let theme_show_color = {|str|
        if $str =~ '^#[a-fA-F\d]{6}$' {
            let contrast_black = contrast $str "#000000"
            let contrast_white = contrast $str "#ffffff"

            {bg: $str fg: (if ($contrast_black > $contrast_white) { "black" } else { "white" })}
        } else {
            "default"
        }
    }

    $env.config.color_config.string = $theme_show_color
}

$env.config.color_config.separator = "dark_gray_dimmed"
$env.config.color_config.row_index = "teal"
$env.config.color_config.filesize = {||
    if $in == 0b {
        "dark_gray_dimmed"
    } else if $in < 1mb {
        "cyan"
    } else if $in > 0.5gb {
        {fg: "yellow" attr: b}
    } else { "blue" }
}
$env.config.color_config.bool = {|| if $in { "light_cyan" } else { "red" } }
$env.config.color_config.leading_trailing_space_bg = {bg: dark_gray}
$env.config.color_config.header = "green"
$env.config.color_config.shape_variable = "blue"
$env.config.color_config.shape_int = "light_magenta"
$env.config.color_config.shape_float = "light_magenta"
$env.config.color_config.shape_garbage = {fg: red attr: u}

load-env {
    PROMPT_INDICATOR_VI_NORMAL: ""
    PROMPT_INDICATOR_VI_INSERT: ""
}

def carapace-completer [spans: list<string>] {
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ $"($spans | last)ERR_?" | is-empty) { $in } else { null }
}

def fish-completer [spans: list<string>] {
    (
        ^fish
        --init-command
        $"
        function commandline
            builtin commandline --input='($spans | str join ' ')' $argv 
        end
        "
        --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
        | from tsv --flexible --noheaders --no-infer
        | rename value description
        | update value {|row|
            let value = $row.value
            let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any { $in in $value }
            if ($need_quote and ($value | path exists)) {
                let expanded_path = if ($value starts-with ~) { $value | path expand --no-symlink } else { $value }
                $'"($expanded_path | str replace --all "\"" "\\\"")"'
            } else { $value }
        }
    )
}

def sudo-completer [spans: list<string>] {
    do $env.config.completions.external.completer ($spans | skip 1)
}

let external_completer = {|spans: list<string>|
    carapace-completer $spans 
    | default --empty { fish-completer $spans }
    # avoid empty result preventing native file completion
    | default --empty null
}

# HACK: @complete doesn't work with aliases (without the expand_alias hack)
def expand_alias [spans: list<string>] {
    let expanded_alias = scope aliases | where name == $spans.0 | get 0?.expansion

    if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row ' ')
    } else {
        $spans
    }
}

def carapace-completer-alias [spans: list<string>] {
    carapace-completer (expand_alias $spans)
}

def fish-completer-alias [spans: list<string>] {
    fish-completer (expand_alias $spans)
}

@complete fish-completer-alias
extern git []

@complete fish-completer-alias
extern gpg []

@complete fish-completer-alias
extern jj []

@complete fish-completer-alias
extern nix []

@complete sudo-completer
extern sudo []

$env.config.table.mode = "compact"
$env.config.table.header_on_separator = true
$env.config.table.trim.truncating_suffix = "…"

$env.config.filesize.unit = "binary"

$env.config.cursor_shape.emacs = "line"
$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

$env.config.edit_mode = "vi"

$env.config.use_kitty_protocol = true

$env.config.show_banner = false

$env.config.history.file_format = "sqlite"
$env.config.history.sync_on_enter = true
$env.config.history.isolation = true
$env.config.history.max_size = 5_000_000

$env.config.datetime_format.normal = '%a, %d %b %Y %H:%M:%S %z' # shows up in displays of variables or other datetime's outside of tables

$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.algorithm = "prefix" # prefix or fuzzy
$env.config.completions.external.completer = $external_completer

$env.config.menus ++= [
    # Configuration for default nushell menus
    # Note the lack of source parameter
    {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20 # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
    }
    {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
    }
    {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20 # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
    }
    {
        name: commands_with_description
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        source: {|buffer position|
            scope commands
            | where name =~ $buffer
            | each {|it| {value: $it.name description: $it.usage} }
        }
    }
] | each {
    upsert style {
        text: default
        description_text: light_gray_dimmed
        selected_text: {fg: default bg: dark_gray_dimmed attr: b}
        match_text: {attr: u}
        selected_match_text: {bg: dark_gray_dimmed attr: urb}
    }
}

$env.config.display_errors.termination_signal = false
$env.config.display_errors.exit_code = false

$env.config.keybindings ++= [
    {
        # fix shift+backspace not working with the kitty keyboard protocol
        name: shift_back
        modifier: Shift
        keycode: Backspace
        mode: [emacs vi_normal vi_insert]
        event: {edit: Backspace}
    }
    {
        name: disable_tab_completion
        modifier: none
        keycode: Tab
        mode: [emacs vi_normal vi_insert]
        event: null
    }
    {
        name: disable_shift_tab_completion
        modifier: Shift
        keycode: BackTab
        mode: [emacs vi_normal vi_insert]
        event: null
    }
    {
        name: completion_menu_next
        modifier: control
        keycode: char_n
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                {send: menu name: completion_menu}
                {send: menunext}
                {edit: complete}
            ]
        }
    }
    {
        name: completion_menu_prev
        modifier: control
        keycode: char_p
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                {send: menu name: completion_menu}
                {send: menuprevious}
                {edit: complete}
            ]
        }
    }
    {
        name: completion_menu_complete
        modifier: control
        keycode: char_y
        mode: [emacs vi_normal vi_insert]
        event: {
            send: Enter
        }
    }
    {
        name: ide_completion_menu
        modifier: control
        keycode: space
        mode: [emacs vi_normal vi_insert]
        event: null
    }
    {
        name: zoxide_jump
        modifier: alt
        keycode: char_z
        mode: [emacs vi_normal vi_insert]
        event: {
            send: executehostcommand
            cmd: "cd (zoxide query --interactive)"
        }
    }
]
