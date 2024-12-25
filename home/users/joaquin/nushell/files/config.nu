let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ $"($spans | last)ERR_?" | is-empty) { $in } else { null }
}

let fish_completer = {|spans: list<string>|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let default_completer = $carapace_completer
let fallback_completer = $fish_completer

let external_completer = {|spans: list<string>|
    let expanded_alias = scope aliases | where name == $spans.0 | get -i 0.expansion
    let spans = if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row ' ')
    } else {
        $spans
    }

    match $spans.0 {
        git => $fish_completer
        gpg => $fish_completer
        _ => $default_completer
    }
    | do $in $spans
    | if (($in | is-empty) and ($fallback_completer != null)) {
        do $fallback_completer $spans
    } else {
        $in
    }
 }

# $env.config.ls.clickable_links = false

$env.config.table.mode = "compact"
$env.config.table.header_on_separator = true
$env.config.table.trim.truncating_suffix = "…"

$env.config.filesize.metric = true

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
    # Example of extra menus created using a nushell source
    # Use the source field to create a list of records that populates
    # the menu
    {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        source: { |buffer, position|
            scope commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
    }
    {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        source: { |buffer, position|
            scope variables
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
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
        source: { |buffer, position|
            scope commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
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
            min_completion_width: 0,
            max_completion_width: 50,
            # max_completion_height: 10, # will be limited by the available lines in the terminal
            padding: 0,
            border: false,
            cursor_offset: 0,
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
    # fix shift+backspace not working with the kitty keyboard protocol
    {
        name: shift_back
        modifier: Shift
        keycode: Backspace
        mode: [emacs, vi_normal, vi_insert]
        event: { edit: Backspace }
    }
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                { edit: complete }
            ]
        }
    }
    {
        name: undo_or_previous_page
        modifier: control
        keycode: char_z
        mode: emacs
        event: {
            until: [
                { send: menupageprevious }
                { edit: undo }
            ]
        }
    }
    {
        name: yank
        modifier: control
        keycode: char_y
        mode: emacs
        event: {
            until: [
                { edit: pastecutbufferafter }
            ]
        }
    }
    # {
    #     name: kill-line
    #     modifier: control
    #     keycode: char_c
    #     mode: [emacs, vi_normal, vi_insert]
    #     event: [
    #         { edit: CutFromStart }
    #         { edit: CutToEnd }
    #     ]
    # }
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
                { send: menu name: ide_completion_menu }
                { send: menunext }
                { edit: complete }
            ]
        }
    }
    {
        name: zoxide_jump
        modifier: alt
        keycode: char_z
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "cd (zoxide query --interactive)"
        }
    }
]
