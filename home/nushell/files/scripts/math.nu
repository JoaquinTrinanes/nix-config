# Finds the prime factor of the specified number
@example "Prime factors of a number" { factor 129 } --result [3 43]
export def factor [n: int]: nothing -> list<int> {
    if $n < 0 {
        error make {
            msg: "Invalid value"
            label: {
                span: (metadata $n).span
                text: "Number can't be negative"
            }
        }
    }

    ^factor $n
    | split row ': '
    | skip 1
    | split row ' '
    | into int
    | sort
}

def gcd-pair [a: int b: int]: nothing -> int {
    mut x = $a
    mut y = $b

    while $y != 0 {
        let temp = $y
        $y = ($x mod $y)
        $x = $temp
    }

    return $x
}

# Find the Greatest Common Divisor of a list of numbers
@example "GCD of two numbers" { gcd 10 5 } --result 5
@example "GCD of many numbers" { gcd 9 6 21 } --result 3
export def gcd [...nums: int]: nothing -> int {
    $nums | reduce --fold 0 {|it acc|
        if $it < 0 {
            error make {
                msg: "Invalid value"
                label: {
                    span: (metadata $it).span
                    text: "Number can't be negative"
                }
            }
        }
        gcd-pair $acc $it
    }
}

# Least common multiple of two numbers
def lcm-pair [a: int b: int]: nothing -> int {
    ($a * $b) // (gcd $a $b)
}

# Find the Least Common Multiple of a list of numbers
@example "GCD of two numbers" { lcm 4 5 } --result 20
@example "GCD of many numbers" { lcm 9 6 21 } --result 126
export def lcm [...nums: int]: nothing -> int {
    $nums | reduce --fold 1 {|it acc|
        if $it < 0 {
            error make {
                msg: "Invalid value"
                label: {
                    span: (metadata $it).span
                    text: "Number can't be negative"
                }
            }
        }
        lcm-pair $acc $it
    }
}
