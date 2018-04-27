#!/bin/sh
# \
exec /usr/local/bin/tclsh "$0" $@"

set liste {}
set MAX 100000
for {set i 0} {$i< $MAX} {incr i} {
    lappend liste [list [expr rand()] [expr rand()] [expr rand()]]
}

puts "liste initialisée"

proc p11 {l} {
    set v 0.0
    foreach e $l {
        set c1 [lindex $e 0]
        set c2 [lindex $e 1]
        set c3 [lindex $e 2]
        set v [expr $v + $c1*$c2*$c3]
    }
    return $v
}

proc p21 {l} {
    set v 0.0
    foreach e $l {
        foreach {c1 c2 c3} $e {
            set v [expr $v + $c1*$c2*$c3]
        }
    }
    return $v
}

proc p12 {l} {
    set v 0.0
    foreach e $l {
        set c1 [lindex $e 0]
        set c2 [lindex $e 1]
        set c3 [lindex $e 2]
        set v [expr $v + $c1*$c2*$c3]
        set v [expr $v + $c1*$c2*$c3]
    }
    return $v
}

proc p22 {l} {
    set v 0.0
    foreach e $l {
        foreach {c1 c2 c3} $e {
            set v [expr $v + $c1*$c2*$c3]
            set v [expr $v + $c1*$c2*$c3]
        }
    }
    return $v
}

set t11 [time {p11 $liste}]
set t21 [time {p21 $liste}]
set t12 [time {p12 $liste}]
set t22 [time {p22 $liste}]
set t11 [lindex $t11 0]
set t21 [lindex $t21 0]
set t12 [lindex $t12 0]
set t22 [lindex $t22 0]
set d10 [expr double($t12 - $t11)/$MAX]
set d20 [expr double($t22 - $t21)/$MAX]
set d01 [expr double($t21 - $t11)/$MAX]
set d02 [expr double($t22 - $t12)/$MAX]


