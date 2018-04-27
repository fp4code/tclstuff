#!/usr/local/bin/tclsh

proc Cnp {n p} {
    if {$p == 0 || $n == $p} {
    	return 1
    }	
    set ret [expr double($n)]
    for {incr n -1} {$p >= 2} {incr n -1; incr p -1} {
    	set ret [expr {($ret*$n)/$p}]
    }
    return $ret
}

proc Nmult {N} {
    set ret [expr pow(2.0, 2*$N)]
    set fact [expr pow(2.0, 2*$N-1)]
    for {set n 1} {$n <= $N} {incr n} {
    	set plus [expr [Cnp $N $n]*pow(1.5, $n)*$fact]
    	puts "$N $n [Cnp $N $n]*[expr pow(1.5, $n)*$fact] $plus"
    	set ret [expr {$ret + $plus}]
    }
    return $ret
}

