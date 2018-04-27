proc t1 {s i} {
    for {} {$i > 0} {incr i -1} {
        set e [lindex $s end]
    }
}
proc t2 {s i} {
    for {} {$i > 0} {incr i -1} {
        set s [lrange $s 0 end]
        set e [lindex $s end]
    }
}
proc t3 {s i} {
    for {} {$i > 0} {incr i -1} {
        set s [eval list $s]
        set e [lindex $s end]
    }
}

proc t11 {s i} {
    for {} {$i > 0} {incr i -1} {
        set j 0
        foreach e $s {
            incr j
        }
    }
}
proc t12 {s i} {
    for {} {$i > 0} {incr i -1} {
        set s [lrange $s 0 end]
        set j 0
        foreach e $s {
            incr j
        }
    }
}
proc t13 {s i} {
    for {} {$i > 0} {incr i -1} {
        set s [eval list $s]
        set j 0
        foreach e $s {
            incr j
        }
    }
}
proc t14 {s i} {
    for {} {$i > 0} {incr i -1} {
        regsub -all {  +} $s " " s
        set j 0
        foreach e $s {
            incr j
        }
    }
}
proc t15 {s i} {
    for {} {$i > 0} {incr i -1} {
        while { [regsub -all "  " $s " " s] } {}
        set j 0
        foreach e $s {
            incr j
        }
    }
}
set s "07     d0    06  10   09 32      37  00"


puts [time {t11 s 10000}]
puts [time {t12 s 10000}]
puts [time {t13 s 10000}]
puts [time {t14 s 10000}]
puts [time {t15 s 10000}]
