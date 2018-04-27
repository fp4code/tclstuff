proc min {a b} {
    if {$a <= $b} {
        return $a
    } else {
        return $b
    }
}

proc max {a b} {
    if {$a >= $b} {
        return $a
    } else {
        return $b
    }
}

proc mm {m n kl ku} {
    for {set j 1} {$j <= $n} {incr j} {
        set k [expr {$ku+1-$j}]
        for {set i [max 1 [expr {$j - $ku}]]} {$i <= [min $m [expr {$j + $kl}]]} {incr i} {
            puts "($i, $j) -> ([expr {$k+$i}], $j)"
        }
    }
}