#!/usr/local/bin/tclsh

# 1999/05/31 (FP)

set hosts [exec rsh -n l2mk /usr/lib/nis/nisaddent -d hosts]

proc compIp {e1 e2} {
    set i1 [split [lindex $e1 0] .]
    set i2 [split [lindex $e2 0] .]
    foreach n1 $i1 n2 $i2 {
	if {$n1 > $n2} {
	    return 1
	}
	if {$n1 < $n2} {
	    return -1
	}
    }
    return 0
}

set hosts [lsort -command compIp [split $hosts \n]]

foreach h $hosts {
    puts $h
}
