#!/usr/local/bin/tclsh

# 1999/06/09 (FP)

set table [exec rsh -n l2mk /usr/lib/nis/nisaddent -d ethers]

proc compEther {e1 e2} {
    set i1 [split [lindex $e1 0] :]
    set i2 [split [lindex $e2 0] :]
    foreach n1 $i1 n2 $i2 {
	set n1 [expr 0x$n1]
	set n2 [expr 0x$n2]
	if {$n1 > $n2} {
	    return 1
	}
	if {$n1 < $n2} {
	    return -1
	}
    }
    return 0
}

set table [lsort -command compEther [split $table \n]]

foreach l $table {
    puts $l
}
