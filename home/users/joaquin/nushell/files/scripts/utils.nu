export def 'list intersection' [a: list, b: list] {
    $a | where $it in $b | where $it in $b | uniq | each {|common|
       let count_a = $a | where $it == $common | length
       let count_b = $b | where $it == $common | length

        [$count_a $count_b] | math min | 1..($in) | each { $common }
    } | flatten
}

def "nu-complete from-path" [] {
    $env.PATH
        | where { path exists }
        | ls --short-names ...$in
        | where type != dir
        # | where name not-in (scope aliases).name
        | rename -c { name: value }
        | select value
        | sort -n
        | uniq
}

# Finds a program file, alias or custom command, and returns its path
export def whichp [
    application: string@"nu-complete from-path" # Application
    --follow(-f) # follow symlinks
] {
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
            msg: $"No ($application) in \(($env.PATH | str join ':')\)",
            label: {
                text: "this"
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
