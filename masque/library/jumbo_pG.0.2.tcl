package provide jumbo_pG 0.2
package require masque 1.0

namespace eval jumbo_pG {
    
    variable blocs [list]
    foreach co {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} {
        foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26} {
            lappend blocs $li$co
        }
    }
    
    variable xyDispo

    set xyDispo()        {   0    0}

    set xyDispo(75x75a)  { 170  295}
    set xyDispo(100x100) { 590  295}
    set xyDispo(50x50)   { 240    0}
    set xyDispo(75x75b)  { 590    0}

    set xyDispo(tlmE10)  { -25  550}
    set xyDispo(tlmB10)  { -25  820}
    set xyDispo(tlmC10)  { -25 1090}
    set xyDispo(tlmE20)  {  35  550}
    set xyDispo(tlmB20)  {  35  820}
    set xyDispo(tlmC20)  {  35 1090}
    set xyDispo(tlmE30)  { 105  550}
    set xyDispo(tlmB30)  { 105  820}
    set xyDispo(tlmC30)  { 105 1090}
    set xyDispo(tlmE40)  { 185  550}
    set xyDispo(tlmB40)  { 185  820}
    set xyDispo(tlmC40)  { 185 1090}
    set xyDispo(tlmE60)  { 275  550}
    set xyDispo(tlmB60)  { 275  820}
    set xyDispo(tlmC60)  { 275 1090}
    set xyDispo(tlmE80)  { 385  550}
    set xyDispo(tlmB80)  { 385  820}
    set xyDispo(tlmC80)  { 385 1090}
    set xyDispo(tlmE120) { 515  550}
    set xyDispo(tlmB120) { 515  820}
    set xyDispo(tlmC120) { 515 1090}

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
    
    if {$typDispo == "jumbo75"} {
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
    if {![regexp {^([a-zA-Z]+)([0-9]+)$} $typDispo tout nature taille]} {
        return -code error "::jumbo_pG::allSymDes : cannot regexp \"$typDispo\""
    }
    switch $nature {
        "jumbo" {
            set dispo ${taille}x${taille}
            foreach bloc $blocs {
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
        } "tlm" {
            set dispo $typDispo
            foreach bloc $blocs {
                foreach couche {C B E} {
                    set symDes ${bloc}tlm${couche}${taille}
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
        } default {
            return {}
        }
    }
}

proc ::jumbo_pG::allTypDispo {} {
    global xyDispo
    return [array names xyDispo]
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

proc ::jumbo_pG::splitGeomTlm {symdes} {
    if {![regexp {^[0-9][0-9][A-Z](tlm[EBC])[0-9]+$} $symdes tout couche]} {
        return -code error "::jumbo_pG::splitGeomTlm : cannot regexp \"$symdes\""
    }
    return $couche
}
