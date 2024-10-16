# Nushell Config File

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ $"($spans | last)ERR_?" | is-empty) { $in } else { null }
}

let fish_completer = {|spans: list<string>|
    @fish@ --command $'complete "--do-complete=($spans | str join " ")"'
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

# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false # true or false to enable or disable the banner
    ls: {
        use_ls_colors: true # use the LS_COLORS environment variable to colorize output
    }
    rm: {
        always_trash: false # always act as if -t was given. Can be overridden with -p
    }
    table: {
        mode: compact # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        header_on_separator: true
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
            truncating_suffix: "…" # "..." # A suffix used by the 'truncating' methodology
            # abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set po
        }
    }
    error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages

    # Whether an error message should be printed if an error of a certain kind is triggered.
    display_errors: {
        exit_code: false # assume the external command prints an error message
        # Core dump errors are always printed, and SIGPIPE never triggers an error.
        # The setting below controls message printing for termination by all other signals.
        termination_signal: false
    }

    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z' # shows up in displays of variables or other datetime's outside of tables
        # table: '%m/%d/%y %I:%M:%S%p'        # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    },
    explore: {
        help_banner: true
        exit_esc: true

        command_bar_text: '#C4C9C6'
        # command_bar: {fg: '#C4C9C6' bg: '#223311' }

        status_bar_background: {fg: '#1D1F21' bg: '#C4C9C6' }
        # status_bar_text: {fg: '#C4C9C6' bg: '#223311' }

        highlight: {bg: 'yellow' fg: 'black' }

        status: {
            # warn: {bg: 'yellow', fg: 'blue'}
            # error: {bg: 'yellow', fg: 'blue'}
            # info: {bg: 'yellow', fg: 'blue'}
        }

        try: {
            # border_color: 'red'
            # highlighted_color: 'blue'

            # reactive: false
        }

        table: {
            # split_line: '#404040'

            cursor: true

            line_index: true
            line_shift: true
            line_head_top: true
            line_head_bottom: true

            show_head: true
            show_index: true

            # selected_cell: {fg: 'white', bg: '#777777'}
            # selected_row: {fg: 'yellow', bg: '#C1C2A3'}
            # selected_column: blue

            # padding_column_right: 2
            # padding_column_left: 2

            # padding_index_left: 2
            # padding_index_right: 1
        }
        config: {
            # cursor_color: {bg: 'yellow' fg: 'black' }

            # border_color: white
            # list_color: green
        }
    }
    history: {
        max_size: 100_000 # Session has to be reloaded for this to take effect
        sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
        file_format: "sqlite" # "sqlite" or "plaintext"
        isolation: true # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
    }
    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true # set this to false to prevent auto-selecting completions when only one remains
        partial: true # set this to false to prevent partial filling of the prompt
        algorithm: "prefix" # prefix or fuzzy
        use_ls_colors: true
        external: {
            enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: $external_completer
        }
    }
    filesize: {
        metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
        format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
    }
    cursor_shape: {
        emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line (line is the default)
        vi_insert: line # block, underscore, line , blink_block, blink_underscore, blink_line (block is the default)
        vi_normal: block # block, underscore, line, blink_block, blink_underscore, blink_line (underscore is the default)
    }
    footer_mode: 25 # always, never, number_of_rows, auto
    float_precision: 2
    use_ansi_coloring: true
    bracketed_paste: true # enable bracketed paste, currently useless on windows
    edit_mode: vi # emacs, vi
    # shell_integration: true # enables terminal markers and a workaround to arrow keys stop working issue
    shell_integration: {
        # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
        osc2: true
        # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
        osc7: true
        # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it
        osc8: false # true
        # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
        osc9_9: false
        # osc133 is several escapes invented by Final Term which include the supported ones below.
        # 133;A - Mark prompt start
        # 133;B - Mark prompt end
        # 133;C - Mark pre-execution
        # 133;D;exit - Mark execution finished with exit code
        # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
        osc133: true
        # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
        # 633;A - Mark prompt start
        # 633;B - Mark prompt end
        # 633;C - Mark pre-execution
        # 633;D;exit - Mark execution finished with exit code
        # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
        # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
        # and also helps with the run recent menu in vscode
        osc633: true
        # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
        reset_application_mode: true
    }
    render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
    highlight_resolved_externals: false # true enables highlighting of external commands in the repl resolved by which.
    recursion_limit: 50 # the maximum number of times nushell allows recursion before stopping it
    plugins: {} # Per-plugin configuration. See https://www.nushell.sh/contributor-book/plugins.html#configuration.
    plugin_gc: {
        # Configuration for plugin garbage collection
        default: {
            enabled: true # true to enable stopping of inactive plugins
            stop_after: 10sec # how long to wait after a plugin is inactive to stop it
        }
        plugins: {
            # alternate configuration for specific plugins, by name, for example:
            #
            # gstat: {
            #     enabled: false
            # }
        }
    }
    use_kitty_protocol: true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this
    hooks: {
        pre_prompt: []
        pre_execution: []
        env_change: {
            PWD: [
            # {|before, after|
            #   null # replace with source code to run if the PWD environment is different since the last repl input
            # }
            ]
        }
        display_output: {
            if (term size).columns >= 100 { table -e } else { table }
        }
        command_not_found: { null } # return an error message when a command is not found
    }
    menus: ([
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
        {
            name: abbr_menu
            only_buffer_difference: false
            marker: "👀 "
            type: {
                layout: columnar
                columns: 1
                col_width: 20
                col_padding: 2
            }
            source: { |buffer, position|
                scope aliases
                | where name == $buffer
                | each { |it| {value: $it.expansion }}
            }
        }
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
            # style: {
            #     # selected_text: {attr: r}
            #     # match_text: {attr: u}
            #     # selected_match_text: {attr: ur}
            # }
        }
    ] | each {|menu| $menu | upsert style {}})
    keybindings: [
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
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
            # event: {
            #     until: [
            #     { send: menu name: completion_menu }
            #     { send: menunext }
            #     ]
            # }
        }
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
            event: { send: menuprevious }
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
        {
            name: abbr
            modifier: control
            keycode: space
            mode: [emacs, vi_normal, vi_insert]
            event: [
                { send: menu name: abbr_menu }
                { edit: insertchar, value: ' '}
            ]
        }
        {
            name: ide_completion_menu
            modifier: control
            keycode: char_n
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: ide_completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
    ]
}

