package provide microCIS 0.1
package require masque 1.0

namespace eval microCIS {
    variable microCISpositions
    array set microCISpositions {
			   0005 {1000     0}
			   0007 {2000     0}
			   0010 {3000     0}
			   0015 {   0 -1000}
			   0020 {1000 -1000}
			   0025 {2000 -1000}
			   0035 {3000 -1000}
			   0050 {   0 -2000}
			   0075 {1000 -2000}
			   0100 {2000 -2000}
			   0150 {3000 -2000}
			   0200 {   0 -3000}
			   0250 {1000 -3000}
			   0350 {2000 -3000}
			   0500 {3000 -3000}
			   3570 { 100 -3000}
    }
    # peut-etre 3570 { 80 -3000}
}

proc ::microCIS::allSymDes {typDispo contourMasque} {
    if {$typDispo == "microCIS"} {
        set ret [list]
	foreach co {0 1 2 3 4} {
	    foreach li {0 1 2 3} {
		set lico $li$co
		if {$lico == "00" || $lico == "04"  || $lico == "30"  || $lico == "34"} {
		    set dims [list 3570]
		} else {
		    set dims [list 0005 0007 0010 0015 0020 0025 0035 0050 0075 0100 0150 0200 0250 0350 0500]
		}
		foreach dim $dims {
		    set symDes $li${co}cis$dim
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

proc ::microCIS::allTypDispo {} {
    return [list microCIS]
}

proc ::microCIS::symDesToPos {symDes} {
    set li [string index $symDes 0]
    set co [string index $symDes 1]
    set dispo [string range $symDes 5 8]
    foreach {x y} $::microCIS::microCISpositions($dispo) {}
    return [list [expr {$x + $co * 4000}] [expr {$y - $li * 4000}]]
}

proc ::microCIS::geomName {symDes} {
    return [string range $symDes 5 8]
}

proc ::microCIS::getSurface {symDes} {
    set diam [string trimleft [::microCIS::geomName $symDes] 0]
    return [expr {$diam*$diam * 3.14159 / 4.0}]
}

proc ::microCIS::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuA
    GPIB::copyGPIB smu3 smuK
}
