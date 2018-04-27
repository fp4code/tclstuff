package provide microRCAST 0.1
package require masque 1.0

namespace eval microRCAST {
    variable microRCASTpositions
    array set microRCASTpositions {
			   A0150 {   0 0}
			   A0200 { 275 0}
			   A0300 { 625 0}
			   A0400 {1075 0}
			   A0600 {1675 0}
			   A0800 {2475 0}
			   A1000 {3475 0}
			   B0150 {3555 -1250}
			   B0200 {3280 -1250}
			   B0300 {2930 -1250}
			   B0400 {2480 -1250}
			   B0600 {1880 -1250}
			   B0800 {1080 -1250}
			   B1000 {  80 -1250}
    }
}


proc ::microRCAST::allSymDes {typDispo contourMasque} {
    if {$typDispo == "microRCAST"} {
        set ret [list]
	foreach co {0 1 2 3 4} {
	    foreach li {0 1 2 3 4 5 6 7} {
		foreach dim {A0150 A0200 A0300 A0400 A0600 A0800 A1000 B0150 B0200 B0300 B0400 B0600 B0800 B1000} {
		    set symDes $li${co}rcast$dim
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

proc ::microRCAST::allTypDispo {} {
    return [list microRCAST]
}

proc ::microRCAST::symDesToPos {symDes} {
    set li [string index $symDes 0]
    set co [string index $symDes 1]
    set dispo [string range $symDes 7 11]
    foreach {x y} $::microRCAST::microRCASTpositions($dispo) {}
    return [list [expr {$x + $co * 4500}] [expr {$y - $li * 1400}]]
}

proc ::microRCAST::geomName {symDes} {
    return [string range $symDes 7 11]
}

proc ::microRCAST::getSurface {symDes} {
    set diam [string trimleft [string range [::microRCAST::geomName $symDes] 1 end] 0]
    return [expr {$diam*$diam * 3.14159 / 4.0}]
}

proc ::microRCAST::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuA
    GPIB::copyGPIB smu3 smuK
}
