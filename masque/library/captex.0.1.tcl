package provide captex 0.1
package require masque 1.0

namespace eval captex {
    variable xybloc
    variable xyfet
    set y 0
    foreach ili {01 02 03 04 05 06 07 08 09 10} {
	set x 0
	foreach ico {A B C D E F G H I J} {
	    set xybloc($ico$ili) [list $x $y]
	    incr x 5000
	}
	incr y -5000
    }
    set y 0
    set x 0
    foreach dispo {A1 A2 B1 B2 C1 C2 D1 D2} {
	set xyfet($dispo) [list $x $y]
	incr x 380
    }
    set y 4400
    set x 0
    foreach dispo {E1 E2 F1 F2 G1 G2 H1 H2} {
	set xyfet($dispo) [list $x $y]
	incr x 380
    }
}

proc ::captex::allSymDes {typDispo contourMasque} {
    if {$typDispo == "captex"} {
        set ret [list]
	foreach bloc [lsort [array names ::captex::xybloc]] {
	    foreach fet [lsort [array names ::captex::xyfet]] {
		set symDes $bloc-fet$fet
		foreach {x y} [::captex::symDesToPos $symDes] {}
		if {[::geom2d::isInternal $contourMasque $x $y]} {
		    lappend ret $symDes
		    puts YES
		} else {
		    puts NO
		}
	    }
	}
    }   
    return $ret
}

proc ::captex::allTypDispo {} {
    return [list captex]
}

proc ::captex::symDesToPos {symDes} {
    puts $symDes
    set bloc [string range $symDes 0 2]
    set fet [string range $symDes 7 8]
    foreach {xb yb} $::captex::xybloc($bloc) {}
    foreach {xf yf} $::captex::xyfet($fet) {}
    return [list [expr {$xb + $xf}] [expr {$yb + $yf}]]
}

proc ::captex::geomName {captex} {
    return captex
}

proc ::captex::getSurface {symDes} {
    return "ne pas utiliser"
}

proc ::captex::configPointes {} {
}
