def "exact from-record" []: [
    record<
        year: int,
        month: int,
        day: int,
        hour: int,
        minute: int,
        second: int,
        nanosecond: int,
        timezone: string
    > -> datetime
] {
    [$in]
    | update cells -c [month day hour minute second] {fill -a r -w 2 -c 0}
    | update year { fill -a r -w 4 -c 0 }
    | update nanosecond { fill -a r -w 9 -c 0 }
    | first
    | format pattern '{year}-{month}-{day}T{hour}:{minute}:{second}.{nanosecond}{timezone}'
    | into datetime -f '%+'
}

# Convert a structured record into a datetime value
export def "from-record" []: [
    record<
        year: int,
        month: int,
        day: int,
        hour: int,
        minute: int,
        second: int,
        nanosecond: int,
        timezone: string
    > -> datetime
] {
    let IN = select -i year month day hour minute second nanosecond timezone
    let IN_t = $IN | transpose key val
    let now = date now | date to-record
    let epoch = 0 | into datetime | date to-record

    let leading_empty = $IN_t | take while { $in.val == null } | length
    let from_now = $now | transpose key val | first $leading_empty
    let rest = $IN_t | skip $leading_empty | update val {|it| default ($epoch | get $it.key) }

    let d = $from_now
    | append $rest
    | transpose -dir
    | update timezone { $IN.timezone? | default $now.timezone }

    $d | exact from-record
}

