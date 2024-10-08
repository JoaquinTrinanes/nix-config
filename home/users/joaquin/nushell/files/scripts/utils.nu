export def 'list intersection' [a: list, b: list] {
    $a | where $it in $b | where $it in $b | uniq | each {|common|
       let count_a = $a | where $it == $common | length
       let count_b = $b | where $it == $common | length

        [$count_a $count_b] | math min | 1..($in) | each { $common }
    } | flatten
}

# Finds a program file, alias or custom command, and returns its path
export def whichp [
    application: string@"nu-complete from-path" # Application
    # --all(-a) # list all executables
] {
    let result = (which $application).0?.path?
    if ($result | is-empty) {
        error make {
            msg: $"No ($application) in \(($env.PATH | str join ':')\)",
            label: {
                text: "this"
                span: (metadata $application).span
            }
        }
    }
    $result
}

export alias w = whichp
