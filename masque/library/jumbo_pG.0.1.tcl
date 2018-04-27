package provide jumbo_pG 0.1
package require masque 1.0

namespace eval jumbo_pG {
    
    variable blocs [list]
    foreach co {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} {
        foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26} {
            lappend blocs $li$co
        }
    }
    
    variable xyDispo
    set xyDispo(75x75a) [list    170   295]
    set xyDispo(100x100) [list  590   295]
    set xyDispo(50x50) [list 240    0]
    set xyDispo(75x75b) [list 590    0]

    variable surfaceDispo
    set surfaceDispo(75x75) [expr {85.*85.}]
    set surfaceDispo(100x100) [expr {110.*110.}]
    set surfaceDispo(50x50) [expr {60.*60.}]

    variable orderDispo
    set orderDispo(75x75a) 1
    set orderDispo(100x100) 2
    set orderDispo(50x50) 3
    set orderDispo(75x75b) 4

}

proc ::jumbo_pG::allSymDes {typDispo contourMasque} {
    variable xyDispo
    variable blocs
    if {$typDispo == "jumbo50"} {
	set ret [list]
	foreach bloc $blocs {
            set dispo 50x50
            set symDes $bloc$dispo
            foreach {x y} [symDesToPos $symDes] {}
            # puts -nonewline "$symDes $x $y "
            if {[geom2d::isInternal $contourMasque $x $y]} {
                    lappend ret $symDes
                # puts YES
            } else {
                # puts NO
            }
	}
	return $ret
    } elseif {$typDispo == "jumbo100"} {
	set ret [list]
	foreach bloc $blocs {
            set dispo 100x100
            set symDes $bloc$dispo
            foreach {x y} [symDesToPos $symDes] {}
            # puts -nonewline "$symDes $x $y "
            if {[geom2d::isInternal $contourMasque $x $y]} {
                    lappend ret $symDes
                # puts YES
            } else {
                # puts NO
            }
	}
	return $ret
    } elseif {$typDispo == "jumbo75"} {
	set ret [list]
	foreach bloc $blocs {
            foreach dispo {75x75a 75x75b} {
                set symDes $bloc$dispo
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

proc ::jumbo_pG::allTypDispo {} {
    # rajouter les autres
    return [list jumbo50 jumbo75 jumbo100 tlm]
}

proc ::jumbo_pG::symDesToPos {symDes} {
    variable xyDispo
    
    set li [string trimleft [string range $symDes 0 1] 0]
    set yibloc [expr {($li-1)*(-2000.)}]
    scan [string range $symDes 2 2] %c co
    scan A %c A
    set xibloc [expr {($co-$A)*2100.}]

    set dispo [string range $symDes 3 end]

    if {![info exists xyDispo($dispo)]} {
        error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    foreach {xd yd} $xyDispo($dispo) {}
    return [list [expr {$xibloc + $xd}] [expr {$yibloc + $yd}]]
}

proc ::jumbo_pG::geomName {symDes} {
    set dispo [string range $symDes 3 end]
    set last [string index $dispo end]
    if {$last == "a" || $last == "b"} {
        set dispo [string range $dispo 0 end-1]
    }
    puts "$symDes -> $dispo"
    return $dispo
}

proc ::jumbo_pG::getSurface {symDes} {
    variable surfaceDispo
    set dispo [::jumbo_pG::geomName $symDes]
    if {![info exists surfaceDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names surfaceDispo]"
    }
    return $surfaceDispo($dispo)
}

proc ::jumbo_pG::triGeom {g1 g2} {
    variable orderGeom
    return [expr {$orderGeom($g1) - $orderGeom($g2)}]
}

proc ::jumbo_pG::triGeomAsFirstElem {l1 l2} {
    return [::jumbo_pG::triGeom [lindex $l1 0] [lindex $l2 0]]
}


proc ::jumbo_pG::configPointes {} {
    GPIB::renameGPIB smuE {}
    GPIB::renameGPIB smuB {}
    GPIB::renameGPIB smuC {}
    GPIB::copyGPIB smu1 smuB
    GPIB::copyGPIB smu2 smuE
    GPIB::copyGPIB smu3 smuC
}
