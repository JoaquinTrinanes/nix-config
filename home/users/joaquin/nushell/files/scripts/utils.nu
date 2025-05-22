export def 'list intersection' [a: list, b: list] {
    $a | where $it in $b | where $it in $b | uniq | each {|common|
        let count_a = $a | where $it == $common | length
        let count_b = $b | where $it == $common | length

        [$count_a $count_b] | math min | 1..($in) | each { $common }
    } | flatten
}

export def "nu-complete from-path" [] {
    $env.PATH
    | where { path exists }
    | ls --full-paths ...$in
    | where type != dir
    | get name
    | wrap description
    | insert value { $in.description | path basename }
    | append (
        scope aliases
        | select name expansion
        | rename value description
        | update description { $"Alias for '($in)'" }
    )
    | sort-by -n value
    | uniq-by value
}

# Finds a program file, alias or custom command, and returns its path
export def whichp [
    application: string@"nu-complete from-path" # Application
    --follow (-f) # follow symlinks
] {
    let expanded_alias = scope aliases | where name == $application | get -i 0.expansion

    if ((not $follow) and ($expanded_alias | is-not-empty)) {
        return $expanded_alias
    }
    let alias_path = scope aliases
    | where name == $application
    | get expansion
    | split words
    | each { first }

    let result = if ($alias_path | is-not-empty) {
        $alias_path | which -a $in.0? ...($in | skip 1) | where path != ''
    } else {
        which -a $application
        | where path != ''
    }

    let result = $result.path?.0?

    if ($result | is-empty) {
        error make {
            msg: $"No ($application) in(char nl)($env.PATH | to nuon -i 4)"
            label: {
                text: "Command not found"
                span: (metadata $application).span
            }
        }
    }
    if $follow {
        realpath $result
    } else {
        $result
    }
}

export alias w = whichp
