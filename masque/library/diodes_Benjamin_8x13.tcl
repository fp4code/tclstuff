package require masque 1.0

namespace eval diodes_Benjamin_8x13 {
}

proc ::diodes_Benjamin_8x13::allSymDes {typDispo contourMasque} {
    if {$typDispo == "diodes"} {
        set dispos [list]
	foreach co {A B C D E F G H I J K L M} {
	    foreach li {0 1 2 3 4 5 6 7} {
		set coli $co$li
		lappend dispos $coli
	    }
	}
	set ret [list]
	foreach symDes $dispos {
	    foreach {x y} [symDesToPos $symDes] {}
	    if {[geom2d::isInternal $contourMasque $x $y]} {
		lappend ret $symDes
		# puts YES
	    } else {
		puts NO
	    }
	}
    }
    return $ret
}

proc ::diodes_Benjamin_8x13::allTypDispo {} {
    return [list diodes]
}

proc ::diodes_Benjamin_8x13::symDesToPos {symDes} {
    set ico [string index $symDes 0]
    set li [string index $symDes 1]
    set co [expr [scan $ico %c] - [scan A %c]]
    return [list [expr {$co*200}] [expr {$li*300}]]
}

proc ::diodes_Benjamin_8x13::geomName {symDes} {
    return diode
}

proc ::diodes_Benjamin_8x13::getSurface {symDes} {
    return 400
}

proc ::diodes_Benjamin_8x13::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuA 
    GPIB::copyGPIB smu3 smuK
}

package provide masque_diodes_Benjamin_8x13 0.1 ; # (FP) 2013-07-23
