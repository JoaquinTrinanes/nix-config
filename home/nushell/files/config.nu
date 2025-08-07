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

if (is-terminal --stdin) {
    $env.GPG_TTY = (tty)
}

load-env {
    PROMPT_INDICATOR_VI_NORMAL: ""
    PROMPT_INDICATOR_VI_INSERT: ""
}

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ $"($spans | last)ERR_?" | is-empty) { $in } else { null }
}

let fish_completer = {|spans: list<string>|
    fish --command $"complete '--do-complete=($spans | str join ' ')'"
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let default_completer = $carapace_completer
let fallback_completer = $fish_completer

let external_completer = {|spans: list<string>|
    let expanded_alias = scope aliases | where name == $spans.0 | get 0?.expansion
    let spans = if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row ' ')
    } else {
        $spans
    }

    let completer = match $spans.0 {
        git => $fish_completer
        gpg => $fish_completer
        jj => $fish_completer
        nix => $fish_completer
        pnpm => $fish_completer
        man => null
        _ => $default_completer
    }

    if ($completer == null) { return null }

    do $completer $spans
    | if (($in | is-empty) and ($fallback_completer != null)) {
        do $fallback_completer $spans
    } else {
        $in
    }
    # avoid empty result preventing native file completion
    | if ($in | is-empty) { null } else { $in }
}

# $env.config.ls.clickable_links = false

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
    # {
    #     name: abbr_menu
    #     only_buffer_difference: false
    #     marker: "👀 "
    #     type: {
    #         layout: columnar
    #         columns: 1
    #         col_width: 20
    #         col_padding: 2
    #     }
    #     source: { |buffer, position|
    #         scope aliases
    #         | where name == $buffer
    #         | each { |it| {value: $it.expansion }}
    #     }
    # }
    {
        name: ide_completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: ide
            min_completion_width: 0
            max_completion_width: 50
            # max_completion_height: 10, # will be limited by the available lines in the terminal
            padding: 0
            border: false
            cursor_offset: 0
            description_mode: "prefer_right"
            min_description_width: 0
            max_description_width: 50
            max_description_height: 10
            description_offset: 1
            # If true, the cursor pos will be corrected, so the suggestions match up with the typed text
            #
            # C:\> str
            #      str join
            #      str trim
            #      str split
            correct_cursor_pos: false
        }
    }
] | each {|menu| $menu | upsert style {} }

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
        name: copy_selection
        modifier: control_shift
        keycode: char_c
        mode: emacs
        event: null # { edit: copyselection }
    }
    # {
    #     name: abbr
    #     modifier: control
    #     keycode: space
    #     mode: [emacs, vi_normal, vi_insert]
    #     event: [
    #         { send: menu name: abbr_menu }
    #         { edit: insertchar, value: ' '}
    #     ]
    # }
    {
        name: ide_completion_menu
        modifier: control
        keycode: space
        # modifier: control
        # keycode: char_n
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                {send: menu name: ide_completion_menu}
                {send: menunext}
                {edit: complete}
            ]
        }
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
