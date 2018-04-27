package provide jumbo_carre 0.1
package require masque 1.0

namespace eval jumbo_carre {
}

proc ::jumbo_carre::allSymDes {typDispo contourMasque} {
    
    if {$typDispo == "jumbo_80"} {
        set ret [list]
	foreach co {0 1 2 3 4 5 6 7 8 9} {
	    foreach li {0 1 2 3 4 5 6 7 8 9} {
		set symDes $li$co
		foreach {x y} [symDesToPos $symDes] {}
		# puts -nonewline "$symDes $x $y "
		if {[geom2d::isInternal $contourMasque $x $y]} {
		    lappend ret $symDes
		    # puts YES
		} else {
		    # puts NO
		}
	    }
	}
	return $ret
    }   
}

proc ::jumbo_carre::allTypDispo {} {
    global xyDispo
    return [array names xyDispo]
}

proc ::jumbo_carre::symDesToPos {symDes} {
    variable xyDispo
    
    set li [string index $symDes 0]
    set co [string index $symDes 1]
    return [list [expr {$co * 1000}] [expr {-$li * 1000}]]
}

proc ::jumbo_carre::geomName {symDes} {
    return jumbo_80
}

proc ::jumbo_carre::getSurface {symDes} {
    return 6400
}

proc ::jumbo_carre::configPointes {} {
    GPIB::renameGPIB smuE {}
    GPIB::renameGPIB smuB {}
    GPIB::renameGPIB smuC {}
    GPIB::copyGPIB smu1 smuB
    GPIB::copyGPIB smu2 smuE
    GPIB::copyGPIB smu3 smuC
}
