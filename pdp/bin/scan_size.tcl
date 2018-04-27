set f [open dir_full.log r]

set ll [split [read -nonewline $f] \n] ; llength $ll

catch {unset RESERVE}
set total 0
for {set i 0} {$i < [llength $ll]} {incr i} {
    set l [lindex $ll $i]
    if {[regexp {^Directory DU0:\[(.+)\]$} $l tout didi]} {
	puts $didi
	incr i 2
	if {[lindex $ll $i] != {}} {
	    return -code error "ligne [expr {$i+1}] non vide"
	}
	incr i
	set l [lindex $ll $i]
	while {$l != {}} {
	    if {![regexp {^([^ ]+) +([^ ]+) +([0-9]+)\./([0-9]+)\. +} $l tout nom position occupe reserve]} {
		return -code error "cannot regexp \"$l\""
	    }
	    if {[info exists RESERVE($didi/$nom)]} {
		return -code error "doublon pour \"$didi/$nom\""
	    }
	    set RESERVE($didi/$nom) $reserve
	    incr i
	    set l [lindex $ll $i]
	}
    }
}

proc concon {&array i1 i2} {
    upvar ${&array} array
    set d [expr {-$array($i1) + $array($i2)}]
    if {$d != 0} {
	return $d
    }
    return [string compare $i1 $i2]
}

set fifi [lsort -command {concon RESERVE} [array names RESERVE]] ; puts trié

set total 0
foreach fi $fifi {
    set s $RESERVE($fi)
    incr total $s
    puts [format "%10d %10d %s" $total $s $fi]

}