# Return the common values shared between two lists, including duplicates.
#
# Each value is kept as many times as it appears in both lists (based on the lower count).
# Values not shared by both lists are removed.
@example "Shared values between two lists" { [1 1 2 3 3 3] | intersection [1 3 3 4] } --result [1 3 3]
@example "Shared values based on minimum count in both lists" { [1 1 2 3 3 3] | intersection [1 3 3 4] } --result [1 3 3]
@example "Intersection of two ranges" { 4..10 | intersection 1..6 } --result [2 2]
export def intersection [other]: [list -> list range -> range] {
    let input = $in
    $input | where $it in $other | where $it in $other | uniq | each {|common|
        let count_a = $input | where $it == $common | length
        let count_b = $other | where $it == $common | length

        [$count_a $count_b] | math min | 1..($in) | each { $common }
    } | flatten
}

# Completes executables in PATH, as well as aliases
export def "nu-complete from-path" [] {
    fd --follow --type executable . --max-depth 1 ...($env.PATH | where { path exists })
    | lines
    | wrap description
    | insert value { get description | path basename }
    | append (
        scope aliases
        | select name description
        | rename --column {name: value}
    )
    | sort-by -n value
    | uniq-by value
}

# Finds a program file, alias or custom command, and returns its path
export def whichp [
    application: string@"nu-complete from-path" # Application
    --follow (-f) # follow symlinks
] {
    let expanded_alias = scope aliases | where name == $application | get 0?.expansion

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
