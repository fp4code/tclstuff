proc printargs {a b args} {
    puts [list printargs $a $b $args]
}

proc callargs {a b args} {
    puts [list callargs $a $b $args]
#bad
    eval printargs $a $b $args
    eval [list printargs $a $b $args]
#goods
    eval [concat [list printargs $a $b] $args]
    eval [list printargs $a $b] $args
}

callargs A "B b" C "F f"

