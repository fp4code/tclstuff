#!/usr/local/bin/tclsh

# 1999/06/03 (FP)

set group [exec rsh -n l2mk /usr/lib/nis/nisaddent -d group]

proc compGID {e1 e2} {
    set n1 [lindex [split $e1 :] 2]
    set n2 [lindex [split $e2 :] 2]
    if {$n1 > $n2} {
	return 1
    }
    if {$n1 < $n2} {
	return -1
    }
    return 0
}

set group [lsort -command compGID [split $group \n]]

foreach h $group {
    puts $h
}
