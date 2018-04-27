package provide twop 0.1
package require masque 1.0

namespace eval twop {
}

proc ::twop::allSymDes {typDispo contourMasque} {
    if {$typDispo == "twop"} {
        set ret [list]
	foreach ili {J I H G F E D C B A} {
	    foreach ico {00 01 02 03 04 05 06 07 08 09
		10 11 12 13 14 15 16 17 18 19
		20 21 22 23 24 25 26 27 28 29} {
		set symdes $ili$ico
		foreach {x y} [::twop::symDesToPos $symdes] {}
		if {[::geom2d::isInternal $contourMasque $x $y]} {
		    lappend ret $symdes
		}
	    }
	}
    }
    return $ret
}

proc ::twop::allTypDispo {} {
    return [list twop]
}

proc ::twop::symDesToPos {symDes} {
    set ili [string range $symDes 0 0]
    set ico [string range $symDes 1 2]
    set li [expr [scan $ili %c] - [scan A %c]]
    set co [string trimleft $ico 0]
    if {$co == ""} {set co 0}
    return [list [expr {$co*(150)}] [expr {$li*(-180)}]]
}

proc ::twop::geomName {twop} {
    return standard
}

proc ::twop::getSurface {symDes} {
    return "ne pas utiliser"
}

proc ::twop::configPointes {} {
}
