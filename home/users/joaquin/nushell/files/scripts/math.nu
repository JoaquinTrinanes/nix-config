export def --wrapped factor [
    n: int,
    --help,
    ...rest
]: nothing -> list<int> {
    ^factor $n ...$rest
    | str replace -r '^[\d]+:' ''
    | split words
    | into int
    | sort
}

export def gcd [a: int, b: int]: nothing -> int {
    list intersection (factor $a) (factor $b) | math product
}

export def lcm [a: int, b: int]: nothing -> int {
    ($a * $b) // (gcd $a $b)
}
