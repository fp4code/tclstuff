package provide metanizo 0.1
package require masque 1.0

namespace eval metanizo {
    variable p4_positions
    array set p4_positions {
	0 p4w08 
	1 p4w09 
        2 p4w10 
	3 p4w11 
	4 p4w12 
	5 full  
	6 p4w13 
	7 p4w14 
	8 p4w15 
	9 p4w16 
	10 p4w17 
	11 blank
    }
}

proc ::metanizo::allSymDes {typDispo contourMasque} {
    if {$typDispo == "p4"} {
        set ret [list]
	for {set ix 0} {$ix < 24}  {incr ix} {
	    for {set iy 0} {$iy < 16} {incr iy} {
		set cx [format %c [expr {$ix + 97}]]
		set cy [format %c [expr {$iy + 97}]]
		set name [metanizo::getnameat $ix $iy]
		set symDes ${cx}${cy}_${name}
		foreach {x y} [symDesToPos $symDes] {}
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

proc metanizo::allTypDispo {} {
    return [list p4]
}

proc metanizo::getnameat {xi yi} {
    set xib [expr {$xi % 6}]
    set yib [expr {1 - $yi % 2}]
    set ii [expr {$xib + 6*$yib}]
    return $metanizo::p4_positions($ii)
}

proc metanizo::symDesToPos {symDes} {
    scan [string index $symDes 0] %c _xi
    scan [string index $symDes 1] %c _yi
    set xi [expr {$_xi - 97}]
    set yi [expr {$_yi - 97}]
    if {[string index $symDes 2] != "_"} {
        return -code error "Bad symDes: $symDes"
    }
    set ename [metanizo::getnameat $xi $yi]
    set name [string range $symDes 3 end]

    if {$xi < 0 || $xi > 23} {
	return -code error "out of bounds x ($xi)"
    } elseif {$yi < 0 || $yi > 15} {
	return -code error "out of bounds y ($yi)"
    } elseif {$ename != $name} {
	return -code error "In $symDes: expected $ename instead of $name"
    }
    return [list [expr {$xi * 400}] [expr {$yi * 400 + ($yi/2)*200}]]
}

proc metanizo::geomName {symDes} {
    return [string range $symDes 3 end]
}

proc metanizo::getSurface {symDes} {
    return [expr {150*300}]
}


proc metanizo::configPointes {} {
}
#    GPIB::renameGPIB smuA {}
#    GPIB::renameGPIB smuK {}
#    GPIB::copyGPIB smu1 smuA
#    GPIB::copyGPIB smu3 smuK
#}

