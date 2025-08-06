def get_package_json_location [] {
    if ('package.json' | path exists) {
        'package.json' | path expand
    } else {
        pnpm root | str trim
    }
}

def package_json [] {
    get_package_json_location | open
}

def 'nu-complete pnpm user scripts' [] {
    try {
        package_json | get scripts | transpose value description
    } catch {
        []
    }
}

def 'nu-complete pnpm installed packages' [] {
    # pnpm list --json | from json | get dependencies | columns
    package_json | transpose depType deps | where depType =~ '(?i)dependencies$' | get deps | each {|it| $it | items {|k, v| {value: $k description: $v} } } | flatten | sort
}

def 'nu-complete pnpm package binaries' [] {
    try {
        # more correct but orders of magnitude slower
        # pnpm bin | ls $in | select name | rename value | insert description 'Package binary' | update value { path basename }
        get_package_json_location
        | path dirname
        | path join node_modules .bin
        | ls $in
        | select name
        | rename value
        | insert description 'Package binary'
        | update value { path basename }
    } catch {
        []
    }
}

def 'nu-complete pnpm' [] {
    let external_completions = do $env.config.completions.external.completer [pnpm '']
    let script_completions = nu-complete pnpm user scripts

    [
        ...$external_completions
        ...$script_completions
    ] | uniq-by value | sort-by value
}

export extern main [
    command?: string@'nu-complete pnpm'
]
