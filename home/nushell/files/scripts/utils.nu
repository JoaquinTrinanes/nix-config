# Return the common values shared between two lists, including duplicates.
#
# Each value is kept as many times as it appears in both lists (based on the lower count).
# Values not shared by both lists are removed.
@example "Shared values between two lists" { [1 1 2 3 3 3] | intersection [1 3 3 4] } --result [1 3 3]
@example "Shared values based on minimum count in both lists" { [1 1 2 3 3 3] | intersection [1 3 3 4] } --result [1 3 3]
@example "Intersection of two ranges" { 4..10 | intersection 1..6 } --result [2 2]
export def intersection [other]: [list -> list range -> list] {
    let input = $in
    $input | where $it in $other | uniq | each {|common|
        let count_a = $input | where $it == $common | length
        let count_b = $other | where $it == $common | length

        [$count_a $count_b] | math min | 1..($in) | each { $common }
    } | flatten
}

# Completes executables in PATH, as well as aliases
export def "nu-complete from-path" [] {
    which -a
    | where type in [external alias]
    | update definition? { $"Alias for `($in)`" }
    | insert description {|it| $it.definition? | default $it.path }
    | sort-by -n command
    | uniq-by command
    | rename -c {command: value}
    | select value description
    | insert display_override { get value }
    | update value { to yaml | str trim }
}

# Finds a program file, alias or custom command, and returns its path
export def whichp [
    application: string@"nu-complete from-path" # Application
    --follow (-f) # follow symlinks
    --all (-a) # list all executables
] {
    let results = which --all=($all) $application

    if ($results | is-empty) {
        error make {
            msg: $"No ($application) in(char nl)($env.PATH | to nuon -i 4)"
            label: {
                text: "Command not found"
                span: (metadata $application).span
            }
        }
    }

    $results
    | update path? {|it| if ($follow) { realpath $it.path } else { $it.path } }
    | insert value {|it| $it.definition? | default $it.path }
    | default {|it| $it.path }
    | get value
    | str join (char nl)
}

export alias w = whichp
