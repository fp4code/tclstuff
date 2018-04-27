package provide bolo 0.1
package require masque 1.0

namespace eval bolo {
    variable xybloc
    array set xybloc {
	01 {0 0}     02 {3500 0}     03 {7000 0}
	04 {0 -2000} 05 {3500 -2000} 06 {7000 -2000}
	07 {0 -4000} 08 {3500 -4000} 09 {7000 -4000}
	10 {0 -6000} 11 {3500 -6000} 12 {7000 -6000}
	13 {0 -8000} 14 {3500 -8000} 15 {7000 -8000}
    }
}

proc ::bolo::allSymDes {typDispo contourMasque} {
    if {$typDispo == "bolo"} {
        set ret [list]
	foreach bloc {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15} {
	    foreach li {1 2 3 4 5 6 7 8} {
		foreach co {1 2 3 4 5 6 7} {
		    set symDes $bloc-$li-$co
		    foreach {x y} [symDesToPos $symDes] {}
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
			# puts YES
		    } else {
			# puts NO
		    }
		}
	    }
	}
    }   
    return $ret
}

proc ::bolo::allTypDispo {} {
    return [list bolo]
}

proc ::bolo::symDesToPos {symDes} {
    set bloc [string range $symDes 0 1]
    set li [string index $symDes 3]
    set co [string index $symDes 5]
    foreach {x y} $::bolo::xybloc($bloc) {}
    return [list [expr {$x + ($co - 1) * 500}] [expr {$y - ($li - 1) * 250}]]
}

proc ::bolo::geomName {bolo} {
    return bolo
}

proc ::bolo::getSurface {symDes} {
    return "ne pas utiliser"
}

proc ::bolo::configPointes {} {
}
