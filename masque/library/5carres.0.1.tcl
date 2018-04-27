package provide 5carres 0.1
package require masque 1.0

namespace eval 5carres {
    variable 5carres_positions
    array set 5carres_positions {
			    050 {   0     0}
			    100 {-200     0}
			    200 { 200   250}
			   300A {-250   200}
			   300B { 150  -200}
    }
}

proc ::5carres::allSymDes {typDispo contourMasque} {
    if {$typDispo == "5carres"} {
        set ret [list]
	foreach co {00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
	    foreach li {00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
		set lico $li$co
		set dims [list 050 100 200 300A 300B]
		foreach dim $dims {
		    set symDes $li${co}_$dim
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

proc ::5carres::allTypDispo {} {
    return [list 5carres]
}

proc ::5carres::symDesToPos {symDes} {
    set li [string trimleft [string range $symDes 0 1] 0]
    set co [string trimleft [string range $symDes 2 3] 0]
    if {$li == ""} {set li 0}
    if {$co == ""} {set co 0}
    set dispo [string range $symDes 5 end]
    foreach {x y} $::5carres::5carres_positions($dispo) {}
    return [list [expr {$x + $co * 1000}] [expr {$y - $li * 1000}]]
}

proc ::5carres::geomName {symDes} {
    return [string range $symDes 5 end]
}

proc ::5carres::getSurface {symDes} {
    set cote [string trimleft [string range $symDes 5 7] 0]
    return [expr {$cote*$cote}]
}


proc ::5carres::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuA
    GPIB::copyGPIB smu3 smuK
}
